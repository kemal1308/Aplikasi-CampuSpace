<%-- 
    Document   : pengaturan
    Created on : 29 May 2026
    Author     : Kemal Farouq
--%>

<%-- 
    Document   : pengaturan
    Created on : 29 May 2026
    Author     : Kemal Farouq
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String idUser = (String) session.getAttribute("idPengguna");
    if(idUser == null) {
        response.sendRedirect("../login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pengaturan Akun - CampuSpace</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
    <script>
        tailwind.config = {
            theme: { extend: { fontFamily: { sans: ['Poppins', 'sans-serif'] }, colors: { primary: '#16325B', secondary: '#22577A', background: '#F4F7F9', textmain: '#1F2937', textmuted: '#6B7280', danger: '#C62828', success: '#10B981' } } }
        }
    </script>
</head>
<body class="antialiased overflow-hidden h-screen w-full flex bg-background">

    <aside class="w-64 bg-[#E3F0F8] flex flex-col h-full z-20 relative border-r border-gray-200 shrink-0">
        <div class="p-6">
            <h2 class="text-2xl font-bold text-primary tracking-tight">CampuSpace</h2>
            <p class="text-[10px] text-textmuted mt-1 uppercase tracking-wider">Portal Peminjaman Fasilitas</p>
        </div>
        <nav class="flex-1 p-4 space-y-2 overflow-y-auto">
            <a href="<%= request.getContextPath() %>/user/beranda.jsp" class="flex items-center gap-3 px-4 py-3 text-sm text-textmuted rounded-xl hover:bg-gray-100 transition"><i data-lucide="layout-dashboard" class="w-5 h-5"></i><span>Beranda</span></a>
            <a href="<%= request.getContextPath() %>/user/katalog.jsp" class="flex items-center gap-3 px-4 py-3 text-sm text-textmuted rounded-xl hover:bg-gray-100 transition"><i data-lucide="search" class="w-5 h-5"></i><span>Cari Fasilitas</span></a>
            <a href="<%= request.getContextPath() %>/user/peminjamanku.jsp" class="flex items-center gap-3 px-4 py-3 text-sm text-textmuted rounded-xl hover:bg-gray-100 transition"><i data-lucide="calendar-days" class="w-5 h-5"></i><span>Jadwal Peminjamanku</span></a>
            <a href="<%= request.getContextPath() %>/user/pengaturan.jsp" class="flex items-center gap-3 px-4 py-3 text-sm font-semibold text-primary bg-[#D6E8F5] rounded-xl transition border-l-4 border-primary"><i data-lucide="settings" class="w-5 h-5"></i><span>Pengaturan Akun</span></a>
            <div class="pt-4 mt-2">
                <a href="<%= request.getContextPath() %>/user/reservasi.jsp" class="bg-primary text-white flex items-center justify-center gap-2 px-4 py-3 text-sm font-semibold rounded-xl hover:bg-secondary transition shadow-md w-full"><i data-lucide="plus" class="w-4 h-4"></i>Ajukan Peminjaman</a>
            </div>
        </nav>
        <div class="p-4 space-y-2 border-t border-gray-200">
            <a href="<%= request.getContextPath() %>/login.jsp" class="w-full flex items-center gap-3 px-4 py-2.5 text-sm font-medium text-white bg-danger rounded-xl hover:bg-red-700 transition shadow-sm"><i data-lucide="log-out" class="w-4 h-4"></i><span>Keluar</span></a>
        </div>
    </aside>

    <main class="flex-1 flex flex-col h-full overflow-hidden bg-white rounded-tl-3xl shadow-[-10px_0_15px_rgba(0,0,0,0.03)] z-10">
        <header class="h-20 bg-white border-b border-gray-100 flex items-center justify-between px-8 z-10 shrink-0">
            <h3 class="text-xl font-bold text-primary">Pengaturan Akun</h3>
            <div class="flex items-center gap-6">
                <div class="relative hidden md:block">
                    <i data-lucide="search" class="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 w-4 h-4"></i>
                    <input type="text" placeholder="Cari sesuatu?" class="pl-9 pr-4 py-2 bg-gray-50 border border-gray-200 rounded-xl text-sm outline-none focus:border-primary transition-all">
                </div>
                <button class="text-gray-500 hover:text-primary relative p-1">
                    <i data-lucide="bell" class="w-5 h-5"></i>
                    <span class="absolute top-1 right-1 w-2 h-2 bg-danger rounded-full border-2 border-white"></span>
                </button>
                <div class="w-10 h-10 rounded-full border-2 border-gray-200 overflow-hidden shadow-sm">
                    <img id="headerAvatar" src="https://i.pravatar.cc/150?img=11" alt="User" class="w-full h-full object-cover">
                </div>
            </div>
        </header>

        <div class="flex-1 overflow-y-auto p-8">
            <div class="max-w-7xl mx-auto mb-6">
                <h1 class="text-3xl font-bold text-primary mb-2">Profil Anda</h1>
                <p class="text-textmuted text-sm">Sunting profil, sesuaikan foto, dan atur keamanan akun Anda.</p>
            </div>

            <div class="max-w-7xl mx-auto space-y-6">
                
                <div class="grid grid-cols-1 xl:grid-cols-12 gap-6">
                    
                    <div class="xl:col-span-5 bg-white rounded-2xl shadow-sm border border-gray-100 p-8 flex flex-col items-center justify-center">
                        
                        <div class="relative w-48 h-48 rounded-full overflow-hidden shadow-lg border-4 border-white mb-6 group cursor-pointer" onclick="document.getElementById('uploadFoto').click()">
                            <img id="profileImage" src="https://i.pravatar.cc/150?img=11" alt="Profile" class="w-full h-full object-cover transition-transform duration-300">
                            <div class="absolute inset-0 bg-black/50 flex flex-col items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity">
                                <i data-lucide="camera" class="w-8 h-8 text-white mb-1"></i>
                                <span class="text-white text-xs font-semibold mt-2">Ubah Foto</span>
                            </div>
                            <input type="file" id="uploadFoto" accept="image/*" class="hidden" onchange="loadNewImage(event)">
                        </div>

                        <div class="w-full text-center px-4">
                            <h4 class="text-base font-bold text-textmain mb-2">Ubah Foto Profil</h4>
                            <p class="text-xs text-textmuted mb-6">Format yang didukung: JPG, PNG, atau JPEG. Ukuran maksimal 2MB.</p>
                            
                            <div class="flex flex-col gap-3">
                                <button type="button" onclick="document.getElementById('uploadFoto').click()" class="w-full flex items-center justify-center gap-2 bg-primary text-white py-3 rounded-xl text-sm font-semibold shadow-sm hover:bg-secondary transition">
                                    <i data-lucide="upload-cloud" class="w-4 h-4"></i> Pilih Foto Baru
                                </button>
                                <button type="button" onclick="alert('Foto profil berhasil disimpan!')" class="w-full py-3 bg-white border border-gray-200 text-gray-700 font-semibold rounded-xl text-sm hover:bg-gray-50 transition shadow-sm">
                                    Simpan Perubahan Foto
                                </button>
                            </div>
                        </div>
                    </div>

                    <div class="xl:col-span-7 bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden flex flex-col">
                        <div class="p-5 border-b border-gray-100 flex items-center gap-2 bg-gray-50">
                            <i data-lucide="user" class="w-5 h-5 text-primary"></i>
                            <h3 class="font-semibold text-textmain">Identitas Pengguna</h3>
                        </div>
                        
                        <form action="../UpdateProfilServlet" method="POST" class="p-6 flex-1 flex flex-col">
                            <div class="space-y-4 mb-6 flex-1">
                                <div>
                                    <label class="block text-xs font-bold text-gray-700 mb-1.5 uppercase tracking-wide">Nama Lengkap / Avatar</label>
                                    <input type="text" value="<%= session.getAttribute("userAktif") != null ? session.getAttribute("userAktif") : "Pengguna" %>" class="w-full px-4 py-3 rounded-xl border border-gray-200 text-sm text-textmain outline-none bg-gray-50" readonly>
                                </div>
                                <div>
                                    <label class="block text-xs font-bold text-gray-700 mb-1.5 uppercase tracking-wide">Identifikator (NIM/NIDN)</label>
                                    <input type="text" name="nim" value="<%= session.getAttribute("nimAktif") != null ? session.getAttribute("nimAktif") : "" %>" placeholder="Masukkan NIM Anda" class="w-full px-4 py-3 rounded-xl border border-gray-300 text-sm text-textmain focus:border-primary outline-none transition bg-white" required>
                                </div>
                                <div>
                                    <label class="block text-xs font-bold text-gray-700 mb-1.5 uppercase tracking-wide">Status Akademik</label>
                                    <input type="text" value="<%= session.getAttribute("roleAktif") != null ? session.getAttribute("roleAktif") : "Mahasiswa" %>" class="w-full px-4 py-3 rounded-xl border border-gray-200 text-sm text-textmain outline-none bg-gray-50" readonly>
                                </div>
                                <div>
                                    <label class="block text-xs font-bold text-gray-700 mb-1.5 uppercase tracking-wide">Departemen / Fakultas</label>
                                    <div class="relative">
                                        <select class="w-full px-4 py-3 rounded-xl border border-gray-200 text-sm text-textmain appearance-none bg-gray-50 outline-none cursor-pointer">
                                            <option>Fakultas Informatika</option>
                                            <option>Fakultas Teknik Elektro</option>
                                            <option>Fakultas Rekayasa Industri</option>
                                        </select>
                                        <i data-lucide="chevron-down" class="absolute right-4 top-1/2 transform -translate-y-1/2 w-4 h-4 text-gray-400"></i>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="pt-4 border-t border-gray-100">
                                <button type="submit" class="w-full py-3.5 bg-primary text-white font-bold rounded-xl hover:bg-secondary transition shadow-md flex items-center justify-center gap-2 text-sm">
                                    Simpan Identitas Profil <i data-lucide="save" class="w-4 h-4"></i>
                                </button>
                            </div>
                        </form>
                    </div>
                </div>

                <div class="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden h-fit">
                    <div class="p-5 border-b border-gray-100 flex items-center gap-2 bg-red-50">
                        <i data-lucide="shield-alert" class="w-5 h-5 text-danger"></i>
                        <h3 class="font-semibold text-danger">Keamanan & Kata Sandi</h3>
                    </div>
                    
                    <div class="p-6">
                        <form action="../UpdatePasswordServlet" method="POST" class="grid grid-cols-1 md:grid-cols-3 gap-6 items-end">
                            <div>
                                <label class="block text-xs font-bold text-gray-700 mb-1.5 uppercase tracking-wide">Sandi Sekarang</label>
                                <input type="password" name="old_password" class="w-full px-4 py-3 rounded-xl border border-gray-200 text-sm focus:border-red-400 outline-none transition" required>
                            </div>
                            <div>
                                <label class="block text-xs font-bold text-gray-700 mb-1.5 uppercase tracking-wide">Sandi Baru</label>
                                <input type="password" name="new_password" class="w-full px-4 py-3 rounded-xl border border-gray-200 text-sm focus:border-red-400 outline-none transition" required>
                            </div>
                            <div>
                                <button type="submit" class="w-full py-3 border-2 border-danger text-danger font-bold text-sm rounded-xl hover:bg-danger hover:text-white transition shadow-sm">
                                    Perbarui Kata Sandi
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
                
            </div>
        </div>
    </main>

    <script> lucide.createIcons({ attrs: { 'stroke-width': 1.5 } }); </script>
    
    <script>
        function loadNewImage(event) {
            const file = event.target.files[0];
            if(file) {
                const reader = new FileReader();
                reader.onload = function(e) {
                    // Update gambar di kotak profil
                    document.getElementById('profileImage').src = e.target.result;
                    // Update gambar di pojok kanan atas layar
                    document.getElementById('headerAvatar').src = e.target.result; 
                }
                reader.readAsDataURL(file);
            }
        }
    </script>
</body>
</html>