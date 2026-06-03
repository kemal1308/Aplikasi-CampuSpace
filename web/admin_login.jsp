<%-- 
    Document   : admin_login
    Created on : 30 May 2026, 06.16.33
    Author     : Kemal Farouq
--%>

<%-- 
    Document   : login (Admin)
    Created on : [Tanggal]
    Author     : Kemal Farouq
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login Portal Admin - CampuSpace</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
    <script>
        tailwind.config = {
            theme: { 
                extend: { 
                    fontFamily: { sans: ['Poppins', 'sans-serif'] }, 
                    colors: { primary: '#16325B', secondary: '#22577A', textmain: '#1F2937', textmuted: '#6B7280' } 
                } 
            }
        }
    </script>
</head>
<body class="bg-[#F4F7F9] flex items-center justify-center min-h-screen p-4 antialiased">

    <div class="bg-white rounded-3xl shadow-2xl overflow-hidden flex flex-col md:flex-row w-full max-w-5xl h-auto md:h-[600px]">
        
        <div class="w-full md:w-1/2 p-10 lg:p-14 flex flex-col justify-center">
            <div class="mb-10">
                <h1 class="text-4xl font-bold text-[#00346F] mb-2">CampuSpace Admin</h1>
                <p class="text-sm text-textmuted">Portal Khusus Administrator Sistem</p>
            </div>

            <form action="AdminLoginServlet" method="POST" class="space-y-5">
                <div>
                    <label class="block text-xs font-bold text-textmain mb-1.5">Username Admin</label>
                    <div class="relative">
                        <i data-lucide="user" class="absolute left-4 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4"></i>
                        <input type="text" name="username" placeholder="Masukkan Username Admin" required 
                               class="w-full pl-11 pr-4 py-3 rounded-xl border border-gray-200 text-sm focus:border-primary focus:ring-1 focus:ring-primary outline-none transition bg-gray-50 focus:bg-white">
                    </div>
                </div>

                <div>
                    <label class="block text-xs font-bold text-textmain mb-1.5">Password</label>
                    <div class="relative">
                        <i data-lucide="lock" class="absolute left-4 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4"></i>
                        <input type="password" name="password" placeholder="Masukkan password Anda" required 
                               class="w-full pl-11 pr-4 py-3 rounded-xl border border-gray-200 text-sm focus:border-primary focus:ring-1 focus:ring-primary outline-none transition bg-gray-50 focus:bg-white">
                    </div>
                </div>

                <div class="pt-4">
                    <button type="submit" class="w-full bg-[#00346F] text-white font-bold py-3.5 rounded-xl hover:bg-secondary transition-colors shadow-md">
                        Masuk
                    </button>
                </div>
            </form>
        </div>

        <div class="hidden md:block w-1/2 relative bg-cover bg-center" style="background-image: url('image/Banner-Telkom-University.jpg');">
            <div class="absolute inset-0 bg-[#16325B]/85 backdrop-brightness-sm"></div>
            
            <div class="relative z-10 h-full p-12 flex flex-col justify-center text-white">
                
                <div class="bg-white w-16 h-16 rounded-2xl flex items-center justify-center mb-6 p-2 shadow-lg">
                    <img src="image/logoTelu.png" alt="Logo Telkom University" class="w-full h-full object-contain">
                </div>
                
                <h2 class="text-[32px] lg:text-4xl font-bold leading-tight mb-4">
                    Kelola Fasilitas dan Reservasi Kampus dengan Lebih Mudah dan Transparan.
                </h2>
                
                <p class="text-blue-50 font-normal leading-relaxed text-sm lg:text-base opacity-90">
                    Halaman khusus Administrator Portal untuk mengelola laboratorium, ruang kelas, ruang seminar, dan fasilitas akademik di lingkungan kampus.
                    <br><br>Gunakan akun admin anda.
                </p>
            </div>
        </div>
        
    </div>

    <script>
        lucide.createIcons({ attrs: { 'stroke-width': 1.5 } });

        // Deteksi jika ada error dari Servlet
        const urlParams = new URLSearchParams(window.location.search);
        if(urlParams.get('error') === 'invalid') {
            alert('Akses Ditolak: Username atau Password Admin salah!');
            // Bersihkan URL agar alert tidak muncul terus saat halaman di-refresh
            window.history.replaceState({}, document.title, window.location.pathname);
        }
    </script>
</body>
</html>
