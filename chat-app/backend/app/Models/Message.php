<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Message extends Model
{
    use HasFactory;

    protected $fillable = [
        'conversation_id',
        'sender_id',
        'content',
        'type', // text, image, file, voice
        'file_path',
        'file_name',
        'file_size',
        'is_edited',
        'reply_to',
    ];

    protected $casts = [
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
        'is_edited' => 'boolean',
    ];

    // العلاقات
    public function conversation()
    {
        return $this->belongsTo(Conversation::class);
    }

    public function sender()
    {
        return $this->belongsTo(User::class, 'sender_id');
    }

    public function replyToMessage()
    {
        return $this->belongsTo(Message::class, 'reply_to');
    }

    public function replies()
    {
        return $this->hasMany(Message::class, 'reply_to');
    }

    public function readReceipts()
    {
        return $this->hasMany(MessageReadReceipt::class);
    }

    // الدوال المساعدة
    public function isText()
    {
        return $this->type === 'text';
    }

    public function isFile()
    {
        return in_array($this->type, ['image', 'file', 'voice']);
    }

    public function markAsRead($userId)
    {
        return $this->readReceipts()->updateOrCreate(
            ['user_id' => $userId],
            ['read_at' => now()]
        );
    }
}