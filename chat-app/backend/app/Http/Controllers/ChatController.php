<?php

namespace App\Http\Controllers;

use App\Models\Conversation;
use App\Models\Message;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Http\JsonResponse;

class ChatController extends Controller
{
    // إنشاء محادثة جديدة أو العثور على محادثة موجودة
    public function createOrGetConversation(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'participant_id' => 'required|exists:users,id',
            'type' => 'sometimes|in:private,group',
            'name' => 'sometimes|string|max:255',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation errors',
                'errors' => $validator->errors()
            ], 422);
        }

        $currentUser = $request->user();
        $participantId = $request->participant_id;
        $type = $request->type ?? 'private';

        if ($type === 'private') {
            // البحث عن محادثة خاصة موجودة
            $conversation = Conversation::where('type', 'private')
                ->whereHas('participants', function ($query) use ($currentUser) {
                    $query->where('user_id', $currentUser->id);
                })
                ->whereHas('participants', function ($query) use ($participantId) {
                    $query->where('user_id', $participantId);
                })
                ->first();

            if (!$conversation) {
                // إنشاء محادثة جديدة
                $conversation = Conversation::create([
                    'type' => 'private',
                    'created_by' => $currentUser->id,
                ]);

                // إضافة المشاركين
                $conversation->participants()->attach([
                    $currentUser->id => ['joined_at' => now()],
                    $participantId => ['joined_at' => now()]
                ]);
            }
        } else {
            // إنشاء مجموعة جديدة
            $conversation = Conversation::create([
                'name' => $request->name,
                'type' => 'group',
                'created_by' => $currentUser->id,
                'description' => $request->description,
            ]);

            $conversation->participants()->attach($currentUser->id, ['joined_at' => now()]);
        }

        $conversation->load(['participants', 'lastMessage.sender']);

        return response()->json([
            'success' => true,
            'conversation' => $conversation
        ]);
    }

    // الحصول على قائمة المحادثات
    public function getConversations(Request $request): JsonResponse
    {
        $user = $request->user();

        $conversations = Conversation::whereHas('participants', function ($query) use ($user) {
            $query->where('user_id', $user->id)
                  ->whereNull('left_at');
        })
        ->with(['participants', 'lastMessage.sender'])
        ->orderBy('updated_at', 'desc')
        ->get();

        return response()->json([
            'success' => true,
            'conversations' => $conversations
        ]);
    }

    // إرسال رسالة
    public function sendMessage(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'conversation_id' => 'required|exists:conversations,id',
            'content' => 'required_if:type,text|string',
            'type' => 'sometimes|in:text,image,file,voice',
            'reply_to' => 'sometimes|exists:messages,id',
            'file_path' => 'sometimes|string',
            'file_name' => 'sometimes|string',
            'file_size' => 'sometimes|integer',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation errors',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = $request->user();
        $conversationId = $request->conversation_id;

        // التحقق من أن المستخدم مشارك في المحادثة
        $conversation = Conversation::whereHas('participants', function ($query) use ($user) {
            $query->where('user_id', $user->id)->whereNull('left_at');
        })->findOrFail($conversationId);

        $message = Message::create([
            'conversation_id' => $conversationId,
            'sender_id' => $user->id,
            'content' => $request->content,
            'type' => $request->type ?? 'text',
            'reply_to' => $request->reply_to,
            'file_path' => $request->file_path,
            'file_name' => $request->file_name,
            'file_size' => $request->file_size,
        ]);

        // تحديث وقت آخر تحديث للمحادثة
        $conversation->touch();

        $message->load(['sender', 'replyToMessage.sender']);

        // TODO: إرسال إشعار فوري للمشاركين الآخرين

        return response()->json([
            'success' => true,
            'message' => $message
        ], 201);
    }

    // الحصول على رسائل المحادثة
    public function getMessages(Request $request, $conversationId): JsonResponse
    {
        $user = $request->user();

        // التحقق من أن المستخدم مشارك في المحادثة
        $conversation = Conversation::whereHas('participants', function ($query) use ($user) {
            $query->where('user_id', $user->id)->whereNull('left_at');
        })->findOrFail($conversationId);

        $page = $request->get('page', 1);
        $limit = $request->get('limit', 50);

        $messages = Message::where('conversation_id', $conversationId)
            ->with(['sender', 'replyToMessage.sender', 'readReceipts'])
            ->orderBy('created_at', 'desc')
            ->paginate($limit, ['*'], 'page', $page);

        return response()->json([
            'success' => true,
            'messages' => $messages
        ]);
    }

    // تحديد الرسالة كمقروءة
    public function markAsRead(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'message_id' => 'required|exists:messages,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation errors',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = $request->user();
        $message = Message::findOrFail($request->message_id);

        $message->markAsRead($user->id);

        return response()->json([
            'success' => true,
            'message' => 'Message marked as read'
        ]);
    }

    // البحث عن المستخدمين
    public function searchUsers(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'query' => 'required|string|min:2',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation errors',
                'errors' => $validator->errors()
            ], 422);
        }

        $query = $request->query;
        $currentUser = $request->user();

        $users = User::where('id', '!=', $currentUser->id)
            ->where(function ($q) use ($query) {
                $q->where('name', 'LIKE', "%{$query}%")
                  ->orWhere('email', 'LIKE', "%{$query}%");
            })
            ->select(['id', 'name', 'email', 'avatar', 'is_online', 'last_seen_at'])
            ->limit(20)
            ->get();

        return response()->json([
            'success' => true,
            'users' => $users
        ]);
    }

    // إضافة مشارك إلى مجموعة
    public function addParticipant(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'conversation_id' => 'required|exists:conversations,id',
            'user_id' => 'required|exists:users,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation errors',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = $request->user();
        $conversation = Conversation::findOrFail($request->conversation_id);

        // التحقق من أن المحادثة مجموعة وأن المستخدم هو المنشئ
        if ($conversation->type !== 'group' || $conversation->created_by !== $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized'
            ], 403);
        }

        $conversation->participants()->syncWithoutDetaching([
            $request->user_id => ['joined_at' => now()]
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Participant added successfully'
        ]);
    }
}