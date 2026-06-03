<%-- 
    Document   : reservasi
    Created on : 30 May 2026
    Author     : Kemal Farouq
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="models.*"%>
<%@page import="controllers.DataManager"%>
<%
    String idUser = (String) session.getAttribute("idPengguna");
    if(idUser == null) {
        response.sendRedirect("../login.jsp");
        return;
    }

    // Mengatasi masalah "null" pada nama pengguna
    String namaUser = (String) session.getAttribute("namaPengguna");
    if (namaUser == null || namaUser.equals("null") || namaUser.trim().isEmpty()) {
        namaUser = (String) session.getAttribute("userAktif");
    }
    if (namaUser == null || namaUser.equals("null") || namaUser.trim().isEmpty()) {
        namaUser = "Shashashany"; 
    }
    String tipeUser = (String) session.getAttribute("tipePengguna");
    if (tipeUser == null) tipeUser = "Mahasiswa";

    // Ambil data fasilitas jika ada ID yang dikirim dari katalog
    String idFasilitasTerpilih = request.getParameter("id");
    DataManager dm = new DataManager();
    Fasilitas fas = null;
    if(idFasilitasTerpilih != null) {
        // Cari nama fasilitas untuk ditampilkan di form
        List<Fasilitas> kats = dm.getAllFasilitas();
        for(Fasilitas f : kats) {
            if(f.getIdFasilitas().equals(idFasilitasTerpilih)) {
                fas = f;
                break;
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ajukan Peminjaman - CampuSpace</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
    <script src="https://unpkg.com/@phosphor-icons/web"></script>
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
            
            <a href="<%= request.getContextPath() %>/user/pengaturan.jsp" class="flex items-center gap-3 px-4 py-3 text-sm text-textmuted rounded-xl hover:bg-gray-100 transition"><i data-lucide="settings" class="w-5 h-5"></i><span>Pengaturan Akun</span></a>
            
            <div class="pt-4 mt-2">
                <a href="<%= request.getContextPath() %>/user/reservasi.jsp" class="flex items-center gap-3 px-4 py-3 text-sm font-semibold text-primary bg-[#D6E8F5] rounded-xl transition border-l-4 border-primary">
                    <i data-lucide="plus" class="w-4 h-4"></i>Ajukan Peminjaman
                </a>
            </div>
        </nav>
        <div class="p-4 space-y-2 border-t border-gray-200">
            <a href="<%= request.getContextPath() %>/login.jsp" class="w-full flex items-center gap-3 px-4 py-2.5 text-sm font-medium text-white bg-danger rounded-xl hover:bg-red-700 transition shadow-sm"><i data-lucide="log-out" class="w-4 h-4"></i><span>Keluar</span></a>
        </div>
    </aside>

    <main class="flex-1 flex flex-col h-full overflow-hidden bg-white rounded-tl-3xl shadow-[-10px_0_15px_rgba(0,0,0,0.03)] z-10">
        <header class="h-20 border-b border-gray-100 flex items-center justify-between px-8 shrink-0">
            <h3 class="text-xl font-bold text-primary">Ajukan Peminjaman</h3>
            <div class="flex items-center gap-5">
                <div class="relative hidden md:block">
                    <i data-lucide="search" class="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 w-4 h-4"></i>
                    <input type="text" placeholder="Cari sesuatu?" class="pl-9 pr-4 py-2 bg-gray-50 border border-gray-200 rounded-xl text-sm outline-none focus:border-primary transition-all">
                </div>
                <button class="text-gray-500 hover:text-primary relative p-1">
                    <i data-lucide="bell" class="w-5 h-5"></i>
                    <span class="absolute top-1 right-1 w-2 h-2 bg-danger rounded-full border-2 border-white"></span>
                </button>
                <div class="flex items-center gap-3 pl-5 border-l border-gray-100">
                    <div class="text-right hidden md:block">
                        <p class="text-xs font-bold text-textmain leading-tight"><%= namaUser %></p>
                        <p class="text-[9px] text-textmuted uppercase font-semibold mt-0.5"><%= idUser %></p>
                    </div>
                    <div class="w-9 h-9 rounded-full border border-gray-200 overflow-hidden shadow-sm">
                        <img src="https://i.pravatar.cc/150?img=11" alt="User" class="w-full h-full object-cover">
                    </div>
                </div>
            </div>
        </header>

        <div class="flex-1 overflow-y-auto p-8 bg-[#FAFAFA]">
            <div class="max-w-7xl mx-auto grid grid-cols-1 lg:grid-cols-3 gap-8">
                
                <div class="lg:col-span-2 space-y-6">
                    <div class="mb-4">
                        <h1 class="text-2xl font-bold text-primary">Form Peminjaman</h1>
                        <p class="text-textmuted text-sm">Lengkapi detail peminjaman untuk memproses reservasi Anda.</p>
                    </div>

                    <form id="formReservasi" onsubmit="return cegahSpamKlik()" action="../ReservasiServlet" method="POST" class="bg-white p-8 rounded-2xl border border-gray-100 shadow-sm space-y-6">
                        
                        <div class="flex flex-col sm:flex-row items-start gap-6 p-5 bg-gray-50 rounded-2xl border border-gray-200 hover:border-primary/20 transition group">
                            <div class="w-full sm:w-40 h-28 rounded-xl bg-gray-200 overflow-hidden shrink-0 shadow-sm border border-gray-300">
                                <% String imgUrl = (fas != null && fas.getGambarUrl() != null && !fas.getGambarUrl().isEmpty()) ? fas.getGambarUrl() : "https://via.placeholder.com/400x250.png?text=Fasilitas"; %>
                                <img src="<%= imgUrl %>" alt="Fasilitas" class="w-full h-full object-cover group-hover:scale-105 transition duration-500">
                            </div>
                            <div class="flex-1 w-full">
                                <div class="flex items-center gap-2 mb-1.5">
                                    <span class="bg-green-100 text-green-700 px-2 py-0.5 rounded text-[10px] font-bold tracking-wide uppercase">Tersedia</span>
                                    <span class="text-[10px] font-bold text-gray-400 uppercase tracking-widest">ID: <%= (fas != null) ? fas.getIdFasilitas() : "Belum Dipilih" %></span>
                                </div>
                                <h3 class="text-lg font-bold text-textmain mb-2"><%= (fas != null) ? fas.getNamaFasilitas() : "Silakan pilih fasilitas dari katalog" %></h3>
                                
                                <p class="text-[11px] text-textmuted leading-relaxed">
                                    <% if(fas instanceof Ruangan) { %>
                                        <i data-lucide="map-pin" class="w-3.5 h-3.5 inline-block mr-1 text-gray-400"></i> <%= ((Ruangan)fas).getLokasiGedung() %> <br>
                                        <span class="mt-1.5 block">
                                            <i data-lucide="users-round" class="w-3.5 h-3.5 inline-block mr-1 text-gray-400"></i> Kapasitas: <%= ((Ruangan)fas).getKapasitas() %> Orang | Fasilitas: <%= ((Ruangan)fas).isBerAc() ? "Dilengkapi AC" : "Tanpa AC" %>
                                        </span>
                                    <% } else if(fas instanceof AlatElektronik) { %>
                                        <i data-lucide="monitor-speaker" class="w-3.5 h-3.5 inline-block mr-1 text-gray-400"></i> Kategori Alat Elektronik <br>
                                        <span class="mt-1.5 block">
                                            <i data-lucide="check-square" class="w-3.5 h-3.5 inline-block mr-1 text-gray-400"></i> Kondisi: <%= ((AlatElektronik)fas).getKondisi() %> | Merk: <%= ((AlatElektronik)fas).getMerkAlat() %>
                                        </span>
                                    <% } else { %>
                                        Silakan kembali ke menu "Cari Fasilitas" untuk memilih item yang ingin dipinjam.
                                    <% } %>
                                </p>
                            </div>
                            <input type="hidden" name="id_fasilitas" value="<%= (fas != null) ? fas.getIdFasilitas() : "" %>" required>
                        </div>

                        <div class="grid grid-cols-1 md:grid-cols-2 gap-6 pt-2">
                            <div class="space-y-2">
                                <label class="text-sm font-semibold text-textmain flex items-center gap-2">Tanggal Mulai Pinjam</label>
                                <input type="date" name="tgl_pinjam" required class="w-full px-4 py-2.5 rounded-xl border border-gray-200 focus:border-primary outline-none transition-all text-sm text-gray-600">
                            </div>
                            <div class="space-y-2">
                                <label class="text-sm font-semibold text-textmain flex items-center gap-2">Tanggal Selesai Pinjam</label>
                                <input type="date" name="tgl_kembali" required class="w-full px-4 py-2.5 rounded-xl border border-gray-200 focus:border-primary outline-none transition-all text-sm text-gray-600">
                            </div>
                        </div>

                        <div class="space-y-2">
                            <label class="text-sm font-semibold text-textmain flex items-center gap-2">Keperluan Peminjaman</label>
                            <textarea name="keperluan" rows="3" placeholder="Contoh: Rapat koordinasi organisasi kemahasiswaan..." class="w-full px-4 py-3 rounded-xl border border-gray-200 focus:border-primary outline-none transition-all text-sm text-gray-600"></textarea>
                        </div>
                        
                        <div class="bg-[#F8F9FA] p-5 rounded-2xl border border-blue-100">
                            <h4 class="text-sm font-bold text-primary flex items-center gap-2 mb-2"><i data-lucide="calculator" class="w-4 h-4"></i> Simulasi Keterlambatan</h4>
                            <p class="text-xs text-textmuted mb-4">Sistem menghitung estimasi denda otomatis berdasarkan durasi peminjaman dan keterlambatan.</p>
                            <div class="flex justify-between items-center text-xs font-semibold border-b border-gray-200 pb-2 mb-2">
                                <span class="text-gray-500">Durasi Peminjaman</span>
                                <span class="text-textmain flex items-center gap-1"><i data-lucide="chevrons-up-down" class="w-3 h-3"></i> Menyesuaikan Input</span>
                            </div>
                            <div class="flex justify-between items-center text-xs font-semibold">
                                <span class="text-gray-500">Status Kuota Pinjam</span>
                                <span class="text-success font-bold">Dalam Batas Wajar</span>
                            </div>
                        </div>

                        <div class="pt-2">
                            <% if(fas == null) { %>
                                <button type="button" onclick="alert('Peringatan: Anda belum memilih fasilitas! Silakan pilih dari menu Cari Fasilitas terlebih dahulu.'); window.location.href='katalog.jsp';" class="w-full py-3.5 bg-gray-400 text-white font-bold rounded-xl cursor-not-allowed shadow-sm flex items-center justify-center gap-2 text-sm">
                                    Pilih Fasilitas Terlebih Dahulu <i data-lucide="alert-circle" class="w-4 h-4"></i>
                                </button>
                            <% } else { %>
                                <button type="submit" id="btnSubmit" class="w-full py-3.5 bg-[#00346F] text-white font-bold rounded-xl hover:bg-secondary transition shadow-md flex items-center justify-center gap-2 text-sm">
                                    Kirim Pengajuan Reservasi <i data-lucide="send" class="w-4 h-4"></i>
                                </button>
                            <% } %>
                        </div>
                    </form>
                </div>

                <div class="space-y-6">
                    
                    <div class="bg-[#00346F] rounded-2xl p-6 text-white shadow-md relative overflow-hidden">
                        <div class="relative z-10 flex items-center gap-4">
                            <div class="w-12 h-12 rounded-xl bg-white/10 flex items-center justify-center shrink-0 border border-white/20">
                                <i data-lucide="user-check" class="w-6 h-6 text-blue-200"></i>
                            </div>
                            <div>
                                <p class="text-[10px] text-blue-200 uppercase tracking-widest font-semibold mb-0.5">Peran Pengguna</p>
                                <h4 class="font-bold text-lg leading-tight"><%= tipeUser %></h4>
                            </div>
                        </div>
                        <div class="mt-6 pt-5 border-t border-white/10 flex justify-between items-center relative z-10">
                            <span class="text-xs text-blue-100 font-medium">Batas Pinjam:</span>
                            <span class="bg-white/20 border border-white/20 px-3 py-1 rounded-full text-xs font-bold shadow-sm">
                                <%= "Dosen".equalsIgnoreCase(tipeUser) ? "7 Hari" : "3 Hari" %>
                            </span>
                        </div>
                        <div class="absolute -right-4 -bottom-4 w-32 h-32 bg-white/5 rounded-full blur-2xl"></div>
                    </div>

                    <div class="bg-[#F8FAFC] rounded-2xl border border-gray-200 p-6 shadow-sm">
                        <h2 class="text-[15px] font-bold text-[#00346F] mb-6">Ringkasan Aturan</h2>
                        <ul class="space-y-5">
                            <li class="flex items-start gap-3">
                                <i data-lucide="calendar-clock" class="w-4 h-4 text-primary shrink-0 mt-0.5"></i>
                                <div>
                                    <p class="text-xs text-textmain leading-relaxed"><strong class="font-bold">Maksimal Peminjaman:</strong> 3 hari untuk Mahasiswa dan 7 hari untuk Dosen.</p>
                                </div>
                            </li>
                            <li class="flex items-start gap-3">
                                <i data-lucide="circle-dollar-sign" class="w-4 h-4 text-danger shrink-0 mt-0.5"></i>
                                <div>
                                    <p class="text-xs text-textmain leading-relaxed"><strong class="font-bold text-danger">Ketentuan Denda:</strong> Keterlambatan pengembalian dikenakan denda sesuai kebijakan universitas.</p>
                                </div>
                            </li>
                            <li class="flex items-start gap-3">
                                <i data-lucide="sparkles" class="w-4 h-4 text-primary shrink-0 mt-0.5"></i>
                                <div>
                                    <p class="text-xs text-textmain leading-relaxed"><strong class="font-bold">Kebersihan:</strong> Peminjam wajib menjaga kebersihan dan mengembalikan peralatan ke posisi semula.</p>
                                </div>
                            </li>
                            <li class="flex items-start gap-3">
                                <i data-lucide="shield-alert" class="w-4 h-4 text-primary shrink-0 mt-0.5"></i>
                                <div>
                                    <p class="text-xs text-textmain leading-relaxed"><strong class="font-bold">Pembatalan:</strong> Minimal 24 jam sebelum waktu peminjaman dimulai.</p>
                                </div>
                            </li>
                        </ul>
                    </div>

                    <div class="bg-white rounded-2xl border border-gray-200 p-6 shadow-sm">
                        <h2 class="text-[14px] font-bold text-textmain mb-4">Butuh Bantuan?</h2>
                        <div class="space-y-3">
                            <a href="#" class="w-full flex justify-between items-center px-4 py-3 bg-[#F8FAFC] border border-gray-100 hover:border-primary/30 rounded-xl group transition-all">
                                <span class="text-xs font-semibold text-textmain">Hubungi Admin Fasilitas</span>
                                <i data-lucide="chevron-right" class="w-4 h-4 text-gray-400 group-hover:text-primary transition-all transform group-hover:translate-x-1"></i>
                            </a>
                            <a href="#" class="w-full flex justify-between items-center px-4 py-3 bg-[#F8FAFC] border border-gray-100 hover:border-primary/30 rounded-xl group transition-all">
                                <span class="text-xs font-semibold text-textmain">Panduan Peminjaman</span>
                                <i data-lucide="chevron-right" class="w-4 h-4 text-gray-400 group-hover:text-primary transition-all transform group-hover:translate-x-1"></i>
                            </a>
                        </div>
                    </div>

                </div>
            </div>
        </div>
    </main>

    <div id="toastNotification" class="fixed top-5 right-5 z-[100] hidden transform transition-all duration-500 ease-in-out translate-x-full">
        <div id="toastBody" class="bg-white border-l-4 shadow-xl rounded-xl p-4 flex items-center gap-4 min-w-[350px]">
            <div id="toastIconContainer" class="p-2 rounded-full">
                <i id="toastIcon" class="text-2xl"></i>
            </div>
            <div>
                <h4 id="toastTitle" class="font-bold text-sm text-gray-800">Judul</h4>
                <p id="toastMessage" class="text-xs text-gray-500 mt-0.5">Pesan detail di sini.</p>
            </div>
        </div>
    </div>

    <script>
        lucide.createIcons({ attrs: { 'stroke-width': 1.5 } });

        // Fungsi Master untuk menampilkan Pop-up Toast
        function showToast(title, message, type) {
            const toast = document.getElementById('toastNotification');
            const body = document.getElementById('toastBody');
            const icon = document.getElementById('toastIcon');
            const iconCont = document.getElementById('toastIconContainer');
            
            document.getElementById('toastTitle').innerText = title;
            document.getElementById('toastMessage').innerText = message;
            
            if (type === 'error') {
                body.className = "bg-white border-l-4 border-red-500 shadow-xl rounded-xl p-4 flex items-center gap-4 min-w-[350px]";
                icon.className = "ph-bold ph-warning-circle text-red-500";
                iconCont.className = "p-2 rounded-full bg-red-50";
            }
            
            toast.classList.remove('hidden');
            setTimeout(() => toast.classList.remove('translate-x-full'), 100);
            
            setTimeout(() => {
                toast.classList.add('translate-x-full');
                setTimeout(() => toast.classList.add('hidden'), 500);
            }, 5000);
        }

        // Tangkap Status Parameter dari URL (Servlet)
        const urlParams = new URLSearchParams(window.location.search);
        const status = urlParams.get('status');
        const batasHari = urlParams.get('max');
        const idFas = urlParams.get('id') || "";

        // ... (kode penangkap status sebelumnya di dalam Reservasi.jsp) ...
        if (status) {
            if (status === 'error_durasi') {
                showToast('Pengajuan Ditolak', 'Durasi reservasi Anda melebihi batas ketentuan. Maksimal untuk akun Anda adalah ' + batasHari + ' hari.', 'error');
            } 
            else if (status === 'error_tanggal_mundur' || status === 'error_tanggal') {
                showToast('Tanggal Tidak Valid', 'Tanggal Selesai Pinjam tidak boleh lebih awal dari Tanggal Mulai Pinjam!', 'error');
            } 
            // ===========================================================
            // TAMBAHKAN BARIS INI UNTUK MENANGKAP ERROR BENTROK JADWAL
            // ===========================================================
            else if (status === 'error_bentrok') {
                const tglBentrok = urlParams.get('tgl');
                showToast('Jadwal Bertabrakan!', 'Fasilitas sudah dibooking pada ' + decodeURIComponent(tglBentrok) + ' (Termasuk sterilisasi H-1). Silakan ganti tanggal Anda.', 'error');
            }
            // ===========================================================
            else if (status === 'error_input') {
                showToast('Data Tidak Lengkap', 'Pastikan Anda sudah memilih fasilitas dari Katalog dengan benar!', 'error');
            } 
        // ... (sisa kode JavaScript) ...
            
            // Bersihkan parameter URL setelah notifikasi dipicu agar bersih saat di-refresh
            window.history.replaceState({}, document.title, window.location.pathname + (idFas ? "?id=" + idFas : ""));
        }

        // SCRIPT ANTI-SPAM KLIK BUTTON
        function cegahSpamKlik() {
            const btn = document.getElementById('btnSubmit');
            if (btn) {
                btn.disabled = true;
                btn.classList.add('opacity-70', 'cursor-wait');
                btn.classList.remove('hover:bg-secondary');
                btn.innerHTML = 'Memproses Pengajuan... <i data-lucide="loader-2" class="w-4 h-4 animate-spin"></i>';
                lucide.createIcons({ attrs: { 'stroke-width': 1.5 } });
            }
            return true;
        }
    </script>
</body>
</html>