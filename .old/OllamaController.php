<?php

namespace App\Http\Controllers;

use App\Enums\LlmJobStatus;
use App\Enums\OllamaJobStatus;
use App\Models\OllamaJob;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;

class OllamaController extends Controller
{
    /**
     * GET /api/v1/ollama/poll
     * 
     * Lokalny komp pyta serwer czy ma zadanie do przetworzenia
     * 
     * @return \Illuminate\Http\JsonResponse
     */
    public function poll(Request $request)
    {
        try {
            // Pobierz następne zadanie w kolejce
            $job = OllamaJob::getNextPendingJob();
            
            if (!$job) {
                // Brak zadań w kolejce
                return response()->json([
                    'has_job' => false,
                    'message' => 'Brak zadań w kolejce',
                ]);
            }
            
            // Oznacz zadanie jako przetwarzane
            $job->markAsProcessing();
            
            Log::info('OllamaController: Zadanie pobrane przez klienta', [
                'job_uuid' => $job->job_uuid,
                'waldus_uuid' => $job->waldus_uuid,
            ]);
            
            // Zwróć zadanie do przetworzenia
            return response()->json([
                'has_job' => true,
                'job' => [
                    'job_uuid' => $job->job_uuid,
                    'request_data' => $job->request_data,
                ],
            ]);
            
        } catch (\Exception $e) {
            Log::error('OllamaController: Błąd podczas poll', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);
            
            return response()->json([
                'has_job' => false,
                'error' => 'Błąd serwera podczas pobierania zadania',
            ], 500);
        }
    }

    /**
     * GET /api/v1/ollama/job/{jobUuid}
     * 
     * Sprawdź status zadania (dla frontendu)
     * 
     * @return \Illuminate\Http\JsonResponse
     */
    public function getJobStatus(Request $request, string $jobUuid)
    {
        try {
            $job = OllamaJob::where('job_uuid', $jobUuid)->first();
            
            if (!$job) {
                return response()->json([
                    'success' => false,
                    'error' => 'Zadanie nie znalezione',
                ], 404);
            }
            
            // Jeśli zadanie jest gotowe, zwróć pełną odpowiedź w formacie LLM
            if ($job->status === OllamaJobStatus::COMPLETED->value) {
                $responseMetadata = $job->response_metadata ?? [];
                return response()->json([
                    'success' => true,
                    'status' => 'completed',
                    'job' => [
                        'job_uuid' => $job->job_uuid,
                        'status' => $job->status,
                        'response_text' => $job->response_text,
                        'response_metadata' => $responseMetadata,
                        'completed_at' => $job->completed_at,
                    ],
                    // Format LLM dla łatwego użycia w frontendzie
                    'llm' => [
                        'text' => $job->response_text ?? '',
                        'usage' => [
                            'input_tokens' => $responseMetadata['input_tokens'] ?? 0,
                            'output_tokens' => $responseMetadata['output_tokens'] ?? 0,
                        ],
                        'raw' => $responseMetadata,
                    ],
                ]);
            }
            
            // Jeśli zadanie jest w trakcie lub nieudane
            return response()->json([
                'success' => true,
                'status' => $job->status,
                'job' => [
                    'job_uuid' => $job->job_uuid,
                    'status' => $job->status,
                    'error_message' => $job->error_message,
                    'created_at' => $job->created_at,
                    'polled_at' => $job->polled_at,
                ],
            ]);
            
        } catch (\Exception $e) {
            Log::error('OllamaController: Błąd podczas pobierania statusu zadania', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);
            
            return response()->json([
                'success' => false,
                'error' => 'Błąd serwera podczas pobierania statusu zadania',
            ], 500);
        }
    }

    /**
     * POST /api/v1/ollama/response
     * 
     * Lokalny komp zwraca odpowiedź z Ollama ??
     *  
     * @return \Illuminate\Http\JsonResponse
     */
    public function response(Request $request)
    {
        try {
            // Walidacja requestu
            $validator = Validator::make($request->all(), [
                'job_uuid' => 'required|string',
                'response_text' => 'required|string',
                'response_metadata' => 'nullable|array',
                'error_message' => 'nullable|string',
            ]);
            
            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'errors' => $validator->errors(),
                ], 422);
            }
            
            // Znajdź zadanie
            $job = OllamaJob::where('job_uuid', $request->job_uuid)->first();
            
            if (!$job) {
                return response()->json([
                    'success' => false,
                    'error' => 'Zadanie nie znalezione',
                ], 404);
            }
            
            // Sprawdź status zadania
            if ($job->status !== LlmJobStatus::PROCESSING->value) {
                return response()->json([
                    'success' => false,
                    'error' => "Zadanie ma nieprawidłowy status: {$job->status}",
                ], 400);
            }
            
            // Jeśli jest błąd, oznacz jako failed
            if ($request->error_message) {
                $job->markAsFailed($request->error_message);
                
                Log::warning('OllamaController: Zadanie zakończone błędem', [
                    'job_uuid' => $job->job_uuid,
                    'error' => $request->error_message,
                ]);
            } else {
                // Oznacz jako ukończone
                $responseText = $request->response_text;
                $responseMetadata = $request->response_metadata ?? [];
                
                $job->markAsCompleted($responseText, $responseMetadata);
                
                // Odśwież zadanie, żeby upewnić się że zostało zapisane
                $job->refresh();
                
                Log::info('OllamaController: Zadanie ukończone pomyślnie', [
                    'job_uuid' => $job->job_uuid,
                    'response_length' => strlen($responseText),
                    'status' => $job->status,
                    'has_response_text' => !empty($job->response_text),
                    'response_metadata' => $responseMetadata,
                ]);
                
                // Sprawdź czy odpowiedź została zapisana
                if (empty($job->response_text)) {
                    Log::error('OllamaController: UWAGA - odpowiedź nie została zapisana!', [
                        'job_uuid' => $job->job_uuid,
                        'expected_length' => strlen($responseText),
                        'actual_length' => strlen($job->response_text ?? ''),
                    ]);
                }
            }
            
            return response()->json([
                'success' => true,
                'message' => 'Odpowiedź zapisana',
            ]);
            
        } catch (\Exception $e) {
            Log::error('OllamaController: Błąd podczas zapisywania odpowiedzi', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);
            
            return response()->json([
                'success' => false,
                'error' => 'Błąd serwera podczas zapisywania odpowiedzi',
            ], 500);
        }
    }
}
