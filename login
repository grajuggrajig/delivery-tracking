<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>เข้าสู่ระบบ - Delivery Tracking & CRM</title>
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Firebase App & Auth SDK (Compat) -->
    <script src="https://www.gstatic.com/firebasejs/9.22.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.22.0/firebase-auth-compat.js"></script>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Plus Jakarta Sans', sans-serif; }
    </style>
</head>
<body class="bg-[#f0f4f8] text-slate-800 h-screen flex items-center justify-center p-4">

    <div class="bg-white rounded-3xl shadow-xl max-w-md w-full p-8 border border-sky-100 transform transition-all">
        <!-- Header Logo / Title -->
        <div class="text-center mb-8">
            <div class="inline-flex items-center justify-center w-16 h-16 bg-sky-50 text-sky-600 rounded-2xl text-2xl mb-3 shadow-2xs border border-sky-100">
                📦
            </div>
            <h1 class="text-2xl font-bold text-slate-800">Delivery Tracking</h1>
            <p class="text-xs text-slate-400 mt-1">กรุณาเข้าสู่ระบบเพื่อใช้งานระบบจัดการจัดส่งสินค้า</p>
        </div>

        <!-- Login Form -->
        <form id="login-form" class="space-y-4">
            <div>
                <label class="block text-xs font-semibold text-slate-600 mb-1">อีเมลผู้ใช้งาน (Email)</label>
                <input type="email" id="username" required placeholder="admin@example.com" class="w-full px-4 py-2.5 text-sm border border-sky-100 bg-sky-50/30 rounded-xl focus:outline-none focus:ring-2 focus:ring-sky-400 focus:bg-white transition">
            </div>

            <div>
                <label class="block text-xs font-semibold text-slate-600 mb-1">รหัสผ่าน (Password)</label>
                <input type="password" id="password" required placeholder="••••••••" class="w-full px-4 py-2.5 text-sm border border-sky-100 bg-sky-50/30 rounded-xl focus:outline-none focus:ring-2 focus:ring-sky-400 focus:bg-white transition">
            </div>

            <div id="error-message" class="text-xs text-rose-500 font-medium text-center hidden">
                ❌ อีเมลหรือรหัสผ่านไม่ถูกต้อง
            </div>

            <!-- ลิงก์ลืมรหัสผ่าน -->
            <div class="text-right mt-1 mb-2">
                <button type="button" onclick="openForgotPasswordModal()" class="text-xs text-sky-600 hover:underline">ลืมรหัสผ่าน?</button>
            </div>

            <button type="submit" id="login-btn" class="w-full py-3 bg-sky-600 hover:bg-sky-700 text-white font-semibold rounded-xl text-sm transition shadow-md shadow-sky-200 flex items-center justify-center gap-2">
                <span>เข้าสู่ระบบ</span>
            </button>
        </form>

        <div class="text-center mt-6 text-[11px] text-slate-400">
            Delivery Tracking System © 2026
        </div>
    </div>

    <!-- Toast Notification Container -->
    <div id="toast-container" class="fixed bottom-5 right-5 z-50 flex flex-col gap-2 pointer-events-none"></div>

    <!-- Modal: ลืมรหัสผ่าน -->
    <div id="forgot-password-modal" class="fixed inset-0 bg-slate-900/40 backdrop-blur-sm z-50 hidden flex items-center justify-center p-4">
        <div class="bg-white rounded-2xl shadow-xl max-w-sm w-full p-6 border border-slate-100">
            <h3 class="text-base font-bold text-slate-800 mb-1">ลืมรหัสผ่าน</h3>
            <p class="text-xs text-slate-400 mb-4">กรอกอีเมลของคุณเพื่อรับลิงก์ตั้งรหัสผ่านใหม่</p>
            
            <input type="email" id="reset-email" placeholder="admin@example.com" class="w-full px-3 py-2 text-sm border border-sky-100 bg-sky-50/30 rounded-xl focus:outline-none focus:ring-2 focus:ring-sky-400 mb-4">
            
            <div class="flex gap-2">
                <button type="button" onclick="closeForgotPasswordModal()" class="flex-1 py-2 rounded-xl text-xs font-semibold bg-slate-100 text-slate-600">ยกเลิก</button>
                <button type="button" onclick="sendPasswordReset()" class="flex-1 py-2 rounded-xl text-xs font-semibold bg-sky-600 text-white">ส่งลิงก์รีเซ็ต</button>
            </div>
        </div>
    </div>

    <script>
        // กำหนดค่า Firebase Config ของคุณ (นำค่าจริงจาก Firebase Console มาใส่แทนด้านล่างนี้)
        const firebaseConfig = {
            apiKey: "AIzaSyBAQ347hnwb3a30u0ckyHK1QWV9eUEMiWE",
            authDomain: "delivery-tracking-2313a.firebaseapp.com",
            projectId: "delivery-tracking-2313a",
            storageBucket: "delivery-tracking-2313a.firebasestorage.app",
            messagingSenderId: "631670801383",
            appId: "1:631670801383:web:e720570af97bad7011f342",
            measurementId: "G-BB2D5DJH3F"
        };
        
        // ป้องกันการ Initialize ซ้ำซ้อน
        if (!firebase.apps.length) {
            firebase.initializeApp(firebaseConfig);
        }

        // ฟังก์ชันแจ้งเตือน Toast
        function showToast(message, type = 'success') {
            const container = document.getElementById('toast-container');
            const toast = document.createElement('div');
            
            const bgColors = {
                success: 'bg-slate-900 text-white border-slate-800',
                error: 'bg-red-600 text-white border-red-500',
                info: 'bg-sky-600 text-white border-sky-500'
            };

            toast.className = `pointer-events-auto flex items-center gap-2 px-4 py-3 rounded-xl text-xs shadow-xl border transition-all duration-300 translate-y-4 opacity-0 ${bgColors[type] || bgColors.success}`;
            toast.innerHTML = `<span>${message}</span>`;
            
            container.appendChild(toast);
            setTimeout(() => toast.classList.remove('translate-y-4', 'opacity-0'), 10);
            setTimeout(() => {
                toast.classList.add('translate-y-4', 'opacity-0');
                setTimeout(() => toast.remove(), 300);
            }, 3000);
        }

        // ฟังก์ชันเปิด-ปิด Modal ลืมรหัสผ่าน (ประกาศไว้นอกสุดเพื่อให้ปุ่ม HTML เรียกใช้งานได้ทันที)
        function openForgotPasswordModal() {
            document.getElementById('forgot-password-modal').classList.remove('hidden');
        }

        function closeForgotPasswordModal() {
            document.getElementById('forgot-password-modal').classList.add('hidden');
        }

        // ฟังก์ชันส่งอีเมลรีเซ็ตรหัสผ่านผ่าน Firebase Auth
        async function sendPasswordReset() {
            const email = document.getElementById('reset-email').value.trim();
            if (!email) {
                showToast('กรุณากรอกอีเมลของคุณ', 'error');
                return;
            }

            try {
                await firebase.auth().sendPasswordResetEmail(email);
                showToast('ส่งลิงก์รีเซ็ตรหัสผ่านไปที่อีเมลของคุณแล้ว', 'success');
                closeForgotPasswordModal();
            } catch (error) {
                showToast('เกิดข้อผิดพลาด: ' + error.message, 'error');
            }
        }

        // จัดการการส่งฟอร์มเข้าสู่ระบบ (Login)
        const loginForm = document.getElementById('login-form');
        const usernameInput = document.getElementById('username');
        const passwordInput = document.getElementById('password');
        const errorMessage = document.getElementById('error-message');
        const loginBtn = document.getElementById('login-btn');

        loginForm.addEventListener('submit', async (e) => {
            e.preventDefault();
            
            const email = usernameInput.value.trim();
            const pass = passwordInput.value.trim();

            try {
                loginBtn.disabled = true;
                loginBtn.textContent = 'กำลังเข้าสู่ระบบ...';
                errorMessage.classList.add('hidden');

                // เข้าสู่ระบบผ่าน Firebase Authentication
                await firebase.auth().signInWithEmailAndPassword(email, pass);

                localStorage.setItem('isLoggedIn', 'true');
                showToast('เข้าสู่ระบบสำเร็จ กำลังพานำทาง...', 'success');

                setTimeout(() => {
                    window.location.href = 'index.html';
                }, 1000);

            } catch (error) {
                loginBtn.disabled = false;
                loginBtn.textContent = 'เข้าสู่ระบบ';
                errorMessage.classList.remove('hidden');
                showToast('อีเมลหรือรหัสผ่านไม่ถูกต้อง', 'error');
            }
        });
    </script>
</body>
</html>
