<%-- 
    Document   : login
    Created on : 29 May 2026, 06.34.26
    Author     : Kemal Farouq
--%>

<%-- 
    Document   : login
    Created on : 29 May 2026, 06.34.26
    Author     : Kemal Farouq
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - CampuSpace</title>
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
                <h1 class="text-4xl font-bold bg-white mb-2">CampuSpace</h1>
                <p class="text-sm text-textmuted">Sistem Reservasi Ruangan dan Fasilitas Terpadu</p>
            </div>

            <form action="LoginServlet" method="POST" class="space-y-5">
                <div>
                    <label class="block text-xs font-bold text-textmain mb-1.5">SSO Username / Email</label>
                    <div class="relative">
                        <i data-lucide="user" class="absolute left-4 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4"></i>
                        <input type="email" name="username" id="emailInput" placeholder="Contoh: nama@student.telkomuniversity.ac.id" required 
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

                <div class="pt-2">
                    <label class="block text-xs font-bold text-textmain mb-2">Masuk Sebagai:</label>
                    <div class="grid grid-cols-2 gap-3">
                        <label class="cursor-pointer relative">
                            <input type="radio" name="role" value="Mahasiswa" class="peer sr-only" checked>
                            <div class="w-full px-4 py-2.5 rounded-xl border border-gray-200 bg-white text-gray-600 text-sm font-semibold flex items-center justify-center gap-2 transition-all peer-checked:bg-primary peer-checked:text-white peer-checked:border-primary shadow-sm">
                                <i data-lucide="graduation-cap" class="w-4 h-4"></i> Mahasiswa
                            </div>
                        </label>
                        <label class="cursor-pointer relative">
                            <input type="radio" name="role" value="Dosen" class="peer sr-only">
                            <div class="w-full px-4 py-2.5 rounded-xl border border-gray-200 bg-white text-gray-600 text-sm font-semibold flex items-center justify-center gap-2 transition-all peer-checked:bg-primary peer-checked:text-white peer-checked:border-primary shadow-sm">
                                <i data-lucide="briefcase" class="w-4 h-4"></i> Dosen
                            </div>
                        </label>
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
                    Reservasi Ruangan dan Peminjaman Fasilitas Kampus Lebih Cepat dan Efisien.
                </h2>
                
                <p class="text-blue-50 font-normal leading-relaxed text-sm lg:text-base opacity-90">
                    Akses laboratorium, ruang kelas, ruang seminar, dan fasilitas akademik di lingkungan kampus dengan mudah dan transparan.
                </p>
            </div>
        </div>
        
    </div>

    <script>
        lucide.createIcons({ attrs: { 'stroke-width': 1.5 } });

        // === 1. LOGIKA PLACEHOLDER DINAMIS ===
        const emailInput = document.getElementById('emailInput');
        const roleRadios = document.querySelectorAll('input[name="role"]');

        roleRadios.forEach(radio => {
            radio.addEventListener('change', (e) => {
                if (e.target.value === 'Mahasiswa') {
                    emailInput.placeholder = 'Contoh: nama@student.telkomuniversity.ac.id';
                } else if (e.target.value === 'Dosen') {
                    emailInput.placeholder = 'Contoh: nama@telkomuniversity.ac.id';
                }
            });
        });

        // === 2. LOGIKA PENANGKAP ERROR ===
        const urlParams = new URLSearchParams(window.location.search);
        const errorType = urlParams.get('error');

        if (errorType === 'domain_mhs') {
            alert('Akses Ditolak: Mahasiswa WAJIB menggunakan domain email @student.telkomuniversity.ac.id!');
            window.history.replaceState({}, document.title, window.location.pathname);
        } 
        else if (errorType === 'domain_dosen') {
            alert('Akses Ditolak: Dosen/Pegawai WAJIB menggunakan domain email @telkomuniversity.ac.id!');
            window.history.replaceState({}, document.title, window.location.pathname);
        } 
        else if (errorType === 'database') {
            alert('Terjadi kesalahan pada sistem atau database. Silakan coba beberapa saat lagi.');
            window.history.replaceState({}, document.title, window.location.pathname);
        }
    </script>
</body>
</html>
