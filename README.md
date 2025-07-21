# تطبيق المحادثة - Laravel & Flutter

تطبيق محادثة كامل يستخدم Laravel كخادم خلفي و Flutter كواجهة أمامية.

## المميزات المتوفرة ✅

### الواجهة الخلفية (Laravel)
- ✅ نظام المصادقة (تسجيل دخول/خروج/تسجيل)
- ✅ إدارة المحادثات والمشاركين
- ✅ إرسال واستقبال الرسائل
- ✅ البحث عن المستخدمين
- ✅ تتبع حالة القراءة للرسائل
- ✅ API RESTful كامل

### الواجهة الأمامية (Flutter)
- ✅ شاشة تسجيل الدخول مع التحقق من صحة البيانات
- ✅ شاشة التسجيل للمستخدمين الجدد
- ✅ شاشة قائمة المحادثات مع تحديث تلقائي
- ✅ شاشة المحادثة مع إرسال الرسائل الفورية
- ✅ شاشة البحث عن المستخدمين
- ✅ نظام تنقل متقدم وإدارة الحالة
- ✅ واجهة مستخدم حديثة ومتجاوبة

## المميزات المخططة 🔄

- 🔄 اتصال WebSocket للمحادثات الفورية
- 🔄 رفع الملفات والصور
- 🔄 الرسائل الصوتية
- 🔄 الإشعارات الفورية
- 🔄 تحسينات إضافية للواجهة

## هيكل المشروع

```
chat-app/
├── laravel_backend/          # الخادم الخلفي
│   ├── app/
│   │   ├── Http/Controllers/ # متحكمات API
│   │   │   ├── AuthController.php
│   │   │   └── ChatController.php
│   │   └── Models/           # نماذج البيانات
│   │       ├── User.php
│   │       ├── Conversation.php
│   │       ├── Message.php
│   │       └── MessageReadReceipt.php
│   ├── database/migrations/  # ملفات قاعدة البيانات
│   └── routes/api.php       # مسارات API
├── flutter_app/             # التطبيق الأمامي
│   ├── lib/
│   │   ├── models/          # نماذج البيانات
│   │   │   ├── user.dart
│   │   │   ├── conversation.dart
│   │   │   └── message.dart
│   │   ├── services/        # خدمات API
│   │   │   └── api_service.dart
│   │   ├── providers/       # إدارة الحالة
│   │   │   ├── auth_provider.dart
│   │   │   └── chat_provider.dart
│   │   ├── screens/         # شاشات التطبيق
│   │   │   ├── login_screen.dart
│   │   │   ├── register_screen.dart
│   │   │   ├── conversations_screen.dart
│   │   │   ├── chat_screen.dart
│   │   │   └── search_users_screen.dart
│   │   └── main.dart        # نقطة البداية
│   └── pubspec.yaml         # تبعيات Flutter
└── README.md                # هذا الملف
```

## إعداد المشروع

### متطلبات النظام

- **PHP** >= 8.1
- **Composer**
- **MySQL** أو **PostgreSQL**
- **Flutter SDK** >= 3.0
- **Dart SDK** >= 2.17

### إعداد الخادم الخلفي (Laravel)

1. **انتقل إلى مجلد الخادم الخلفي:**
   ```bash
   cd laravel_backend
   ```

2. **تثبيت التبعيات:**
   ```bash
   composer install
   ```

3. **إعداد ملف البيئة:**
   ```bash
   cp .env.example .env
   ```

4. **تحديث إعدادات قاعدة البيانات في `.env`:**
   ```env
   DB_CONNECTION=mysql
   DB_HOST=127.0.0.1
   DB_PORT=3306
   DB_DATABASE=chat_app
   DB_USERNAME=your_username
   DB_PASSWORD=your_password
   ```

5. **إنشاء مفتاح التطبيق:**
   ```bash
   php artisan key:generate
   ```

6. **تشغيل migrations:**
   ```bash
   php artisan migrate
   ```

7. **تشغيل الخادم:**
   ```bash
   php artisan serve
   ```

   الخادم سيعمل على: `http://localhost:8000`

### إعداد التطبيق الأمامي (Flutter)

1. **انتقل إلى مجلد Flutter:**
   ```bash
   cd flutter_app
   ```

2. **تثبيت التبعيات:**
   ```bash
   flutter pub get
   ```

3. **تحديث عنوان API في `lib/services/api_service.dart`:**
   ```dart
   static const String baseUrl = 'http://localhost:8000/api';
   // أو عنوان الخادم الخاص بك
   ```

4. **تشغيل التطبيق:**
   ```bash
   flutter run
   ```

## API Endpoints

### المصادقة
- `POST /api/register` - تسجيل مستخدم جديد
- `POST /api/login` - تسجيل الدخول
- `POST /api/logout` - تسجيل الخروج
- `GET /api/profile` - الحصول على بيانات المستخدم

### المحادثات
- `GET /api/conversations` - قائمة المحادثات
- `POST /api/conversations` - إنشاء محادثة جديدة
- `GET /api/conversations/{id}/messages` - رسائل محادثة محددة
- `POST /api/conversations/{id}/messages` - إرسال رسالة

### المستخدمين
- `GET /api/users/search` - البحث عن المستخدمين

### المرفقات (مخطط لها)
- `POST /api/messages/{id}/attachments` - رفع مرفق
- `GET /api/attachments/{id}` - تحميل مرفق

## نصائح للتطوير

### إضافة ميزات جديدة

1. **في Laravel:**
   - أضف routes جديدة في `routes/api.php`
   - أنشئ controllers في `app/Http/Controllers/`
   - أضف migrations للتعديلات على قاعدة البيانات

2. **في Flutter:**
   - أضف screens جديدة في `lib/screens/`
   - حدث `lib/services/api_service.dart` للـ API calls الجديدة
   - أضف routes في `lib/main.dart`

### اختبار الـ API

يمكن استخدام **Postman** أو **curl** لاختبار endpoints:

```bash
# تسجيل مستخدم جديد
curl -X POST http://localhost:8000/api/register \
  -H "Content-Type: application/json" \
  -d '{"name":"أحمد","email":"ahmed@example.com","password":"123456","password_confirmation":"123456"}'

# تسجيل الدخول
curl -X POST http://localhost:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"ahmed@example.com","password":"123456"}'
```

### نشر التطبيق

#### Laravel (الخادم الخلفي)
- استخدم **Laravel Forge** أو **DigitalOcean**
- تأكد من تكوين HTTPS و CORS
- استخدم **Redis** للـ sessions والـ cache

#### Flutter (التطبيق الأمامي)
- للأندرويد: `flutter build apk`
- للـ iOS: `flutter build ios`
- للويب: `flutter build web`

### مشاكل شائعة وحلولها

1. **خطأ CORS:** تأكد من تكوين CORS في Laravel config
2. **مشاكل في الاتصال:** تحقق من عنوان baseUrl في Flutter
3. **خطأ في المصادقة:** تأكد من صحة tokens والـ headers

## المساهمة

1. Fork المشروع
2. أنشئ branch للميزة الجديدة
3. Commit التغييرات
4. Push إلى Branch
5. أنشئ Pull Request

## الترخيص

هذا المشروع مرخص تحت رخصة MIT.

---

**ملاحظة:** هذا المشروع في مرحلة التطوير. المميزات الأساسية مكتملة والمميزات المتقدمة قيد التطوير.