# تطبيق المحادثة - Flutter & Laravel

تطبيق محادثة شامل باستخدام Flutter للواجهة الأمامية و Laravel للواجهة الخلفية.

## المتطلبات

### للباك-إند (Laravel):
- PHP 8.1 أو أحدث
- Composer
- MySQL/PostgreSQL
- Node.js & NPM (للأصول)

### للفرونت-إند (Flutter):
- Flutter SDK 3.0+
- Dart SDK
- محرر النصوص (VS Code, Android Studio)

## تعليمات التثبيت

### 1. إعداد الباك-إند (Laravel)

```bash
# الانتقال إلى مجلد الباك-إند
cd backend

# تثبيت التبعيات
composer install

# نسخ ملف البيئة
cp .env.example .env

# إنشاء مفتاح التطبيق
php artisan key:generate

# إعداد قاعدة البيانات في ملف .env
# DB_CONNECTION=mysql
# DB_HOST=127.0.0.1
# DB_PORT=3306
# DB_DATABASE=chat_app
# DB_USERNAME=root
# DB_PASSWORD=

# تشغيل هجرات قاعدة البيانات
php artisan migrate

# تشغيل الخادم
php artisan serve
```

### 2. إعداد الفرونت-إند (Flutter)

```bash
# الانتقال إلى مجلد الفرونت-إند
cd frontend

# تثبيت التبعيات
flutter pub get

# إنشاء ملفات JSON (إذا لزم الأمر)
flutter packages pub run build_runner build

# تشغيل التطبيق
flutter run
```

## الميزات

### الميزات المتاحة:
- ✅ تسجيل المستخدمين وتسجيل الدخول
- ✅ المحادثات الخاصة
- ✅ إرسال واستقبال الرسائل النصية
- ✅ قائمة المحادثات
- ✅ البحث عن المستخدمين
- ✅ حالة الاتصال (متصل/غير متصل)

### الميزات المخططة:
- ⏳ المحادثات الجماعية
- ⏳ إرسال الصور والملفات
- ⏳ الرسائل الصوتية
- ⏳ إشعارات الدفع
- ⏳ المحادثات الفورية (WebSocket)
- ⏳ حفظ الرسائل غير المقروءة
- ⏳ حالة قراءة الرسائل

## هيكل المشروع

```
chat-app/
├── backend/                 # Laravel API
│   ├── app/
│   │   ├── Http/Controllers/
│   │   │   ├── AuthController.php
│   │   │   └── ChatController.php
│   │   └── Models/
│   │       ├── User.php
│   │       ├── Conversation.php
│   │       ├── Message.php
│   │       └── MessageReadReceipt.php
│   ├── database/migrations/
│   └── routes/api.php
│
└── frontend/               # Flutter App
    ├── lib/
    │   ├── models/        # نماذج البيانات
    │   ├── services/      # خدمات API
    │   ├── providers/     # إدارة الحالة
    │   ├── screens/       # شاشات التطبيق
    │   └── widgets/       # عناصر واجهة قابلة للإعادة
    └── assets/           # الصور والخطوط
```

## واجهات API المتاحة

### المصادقة:
- `POST /api/auth/register` - تسجيل مستخدم جديد
- `POST /api/auth/login` - تسجيل الدخول
- `POST /api/auth/logout` - تسجيل الخروج
- `GET /api/auth/profile` - الحصول على الملف الشخصي

### المحادثات:
- `GET /api/chat/conversations` - قائمة المحادثات
- `POST /api/chat/conversations` - إنشاء محادثة جديدة
- `GET /api/chat/conversations/{id}/messages` - رسائل المحادثة
- `POST /api/chat/messages` - إرسال رسالة
- `POST /api/chat/messages/mark-read` - تحديد الرسالة كمقروءة

### أخرى:
- `GET /api/chat/users/search` - البحث عن المستخدمين
- `GET /api/health` - حالة الخادم

## نصائح التطوير

### تشغيل الخادم مع إعادة التحميل التلقائي:
```bash
# Laravel
php artisan serve --host=0.0.0.0 --port=8000

# Flutter (تطوير)
flutter run -d chrome --web-renderer html
```

### تصحيح الأخطاء:
```bash
# عرض سجلات Laravel
tail -f storage/logs/laravel.log

# تصحيح أخطاء Flutter
flutter logs
```

## اختبار API

يمكنك استخدام أدوات مثل Postman أو curl لاختبار API:

```bash
# تسجيل مستخدم جديد
curl -X POST http://localhost:8000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "أحمد محمد",
    "email": "ahmed@example.com",
    "password": "password123",
    "password_confirmation": "password123"
  }'

# تسجيل الدخول
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "ahmed@example.com",
    "password": "password123"
  }'
```

## المساهمة

1. انشئ fork للمشروع
2. أنشئ فرع للميزة الجديدة (`git checkout -b feature/amazing-feature`)
3. قم بتسجيل التغييرات (`git commit -m 'Add some amazing feature'`)
4. ادفع إلى الفرع (`git push origin feature/amazing-feature`)
5. افتح Pull Request

## الترخيص

هذا المشروع مرخص تحت رخصة MIT - راجع ملف [LICENSE](LICENSE) للتفاصيل.

## الدعم

إذا واجهت أي مشاكل، يرجى فتح issue في GitHub أو التواصل معنا.

---

**ملاحظة**: هذا مشروع تعليمي وقد يحتاج إلى تحسينات إضافية للاستخدام في الإنتاج.