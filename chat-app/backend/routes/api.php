<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\ChatController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

// مسارات المصادقة
Route::prefix('auth')->group(function () {
    Route::post('register', [AuthController::class, 'register']);
    Route::post('login', [AuthController::class, 'login']);
    
    Route::middleware('auth:sanctum')->group(function () {
        Route::post('logout', [AuthController::class, 'logout']);
        Route::get('profile', [AuthController::class, 'profile']);
        Route::put('profile', [AuthController::class, 'updateProfile']);
    });
});

// مسارات المحادثة (تتطلب مصادقة)
Route::middleware('auth:sanctum')->prefix('chat')->group(function () {
    // المحادثات
    Route::get('conversations', [ChatController::class, 'getConversations']);
    Route::post('conversations', [ChatController::class, 'createOrGetConversation']);
    Route::post('conversations/participants', [ChatController::class, 'addParticipant']);
    
    // الرسائل
    Route::get('conversations/{conversationId}/messages', [ChatController::class, 'getMessages']);
    Route::post('messages', [ChatController::class, 'sendMessage']);
    Route::post('messages/mark-read', [ChatController::class, 'markAsRead']);
    
    // البحث
    Route::get('users/search', [ChatController::class, 'searchUsers']);
});

// مسار للتحقق من حالة الـ API
Route::get('health', function () {
    return response()->json([
        'status' => 'OK',
        'timestamp' => now(),
        'service' => 'Chat App API'
    ]);
});

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});