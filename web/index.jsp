<%-- 
    Document   : index
    Created on : 28 May 2026, 20.39.26
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
            theme: { extend: { fontFamily: { sans: ['Poppins', 'sans-serif'], },
                colors: { primary: '#16325B', secondary: '#22577A', background: '#F4F7F9', textmain: '#1F2937', textmuted: '#6B7280' }
            }}
        }
    </script>
    <style>body { font-family: 'Poppins', sans-serif; font-weight: 400; background-color: #F4F7F9; color: #1F2937; }</style>
</head>
<body class="antialiased h-screen w-full flex items-center justify-center p-6">
    <div class="bg-white rounded-2xl shadow-xl w-full max-w-6xl h-[85vh] flex overflow-hidden border border-gray-100">
        <div class="w-1/2 p-12 flex flex-col justify-center relative">
            <div class="mb-10">
                <h1 class="text-4xl font-bold text-primary mb-2">CampuSpace</h1>
                <p class="text-textmuted text-sm">Sistem Reservasi Ruangan dan Fasilitas Terpadu</p>
            </div>

            <form action="LoginServlet" method="POST" class="space-y-4">
                <div>
                    <label class="block text-sm font-semibold text-textmain mb-1">SSO Username</label>
                    <div class="relative">
                        <i data-lucide="user" class="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5"></i>
                        <input type="text" name="username" placeholder="Contoh: ahmadbakrie@univ.ac.id" required class="w-full pl-10 pr-4 py-3 rounded-lg border border-gray-300 focus:outline-none focus:border-primary text-sm">
                    </div>
                </div>

                <div>
                    <label class="block text-sm font-semibold text-textmain mb-1">Password</label>
                    <div class="relative">
                        <i data-lucide="lock" class="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5"></i>
                        <input type="password" name="password" placeholder="Masukkan password Anda" required class="w-full pl-10 pr-10 py-3 rounded-lg border border-gray-300 focus:outline-none focus:border-primary text-sm">
                    </div>
                </div>

                <div>
                    <label class="block text-sm font-semibold text-textmain mb-2">Masuk Sebagai:</label>
                    <div class="flex gap-4">
                        <label class="flex-1 cursor-pointer">
                            <input type="radio" name="role" value="mahasiswa" class="peer sr-only" checked>
                            <div class="w-full py-2 border border-gray-300 rounded-lg flex items-center justify-center gap-2 text-sm peer-checked:bg-primary peer-checked:text-white transition">
                                <i data-lucide="graduation-cap" class="w-4 h-4"></i> Mahasiswa
                            </div>
                        </label>
                        <label class="flex-1 cursor-pointer">
                            <input type="radio" name="role" value="dosen" class="peer sr-only">
                            <div class="w-full py-2 border border-gray-300 rounded-lg flex items-center justify-center gap-2 text-sm peer-checked:bg-primary peer-checked:text-white transition">
                                <i data-lucide="briefcase" class="w-4 h-4"></i> Dosen
                            </div>
                        </label>
                    </div>
                </div>

                <button type="submit" class="w-full bg-primary text-white font-semibold py-3 rounded-lg hover:bg-[#22577A] transition mt-4 shadow-md">Masuk</button>
            </form>
        </div>

        <div class="w-1/2 bg-primary relative overflow-hidden flex flex-col justify-center p-12 text-white">
            <div class="absolute inset-0 bg-[#22577A]/80 mix-blend-multiply z-10"></div>
            <img src="https://images.unsplash.com/photo-1541339907198-e08756dedf3f?ixlib=rb-4.0.3" class="absolute inset-0 w-full h-full object-cover opacity-40">
            <div class="relative z-20">
                <div class="bg-white w-16 h-16 rounded-xl flex items-center justify-center mb-8 shadow-lg"><i data-lucide="building-2" class="w-8 h-8 text-primary"></i></div>
                <h2 class="text-4xl font-semibold leading-tight mb-4">Reservasi Ruangan dan Peminjaman Fasilitas Kampus Lebih Cepat dan Efisien.</h2>
            </div>
        </div>
    </div>
    <script>lucide.createIcons({ attrs: { 'stroke-width': 1.75 } });</script>
</body>
</html>