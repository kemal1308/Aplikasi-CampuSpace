<%-- 
    Document   : beranda
    Created on : 30 May 2026
    Author     : Kemal Farouq
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="models.*"%>
<%@page import="controllers.DataManager"%>
<%@page import="java.text.SimpleDateFormat"%>
<%
    String idUser = (String) session.getAttribute("idPengguna");
    if(idUser == null) {
        response.sendRedirect("../login.jsp");
        return;
    }

    String namaUser = (String) session.getAttribute("namaPengguna");
    if (namaUser == null || namaUser.equals("null") || namaUser.trim().isEmpty()) {
        namaUser = (String) session.getAttribute("userAktif");
    }
    if (namaUser == null || namaUser.equals("null") || namaUser.trim().isEmpty()) {
        namaUser = "Shashashany"; 
    }
    
    String tipePengguna = (String) session.getAttribute("tipePengguna");

    DataManager dm = new DataManager();
    List<Peminjaman> listPeminjaman = dm.getPeminjamanByPengguna(idUser);
    List<Peminjaman> listAktivitas = dm.getRecentAktivitasByPengguna(idUser);
    List<Fasilitas> listFasilitasTersedia = dm.getAvailableFasilitasLimit(3); 

    Peminjaman reservasiSaatIni = null;
    Peminjaman dendaPengguna = null;
    
    if (listPeminjaman != null) {
        for (Peminjaman p : listPeminjaman) {
            if ("PENDING".equals(p.getStatusPeminjaman()) || "APPROVED".equals(p.getStatusPeminjaman())) {
                reservasiSaatIni = p;
            }
            if ("TERDENDA".equals(p.getStatusDenda()) || "MENUNGGU_VERIFIKASI".equals(p.getStatusDenda())) {
                dendaPengguna = p;
            }
        }
    }

    SimpleDateFormat fmtBulan = new SimpleDateFormat("MMM");
    SimpleDateFormat fmtTanggal = new SimpleDateFormat("dd");
    SimpleDateFormat fmtTglPenuh = new SimpleDateFormat("dd MMM yyyy");
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Beranda - CampuSpace</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
    <script>
        tailwind.config = {
            theme: { extend: { fontFamily: { sans: ['Poppins', 'sans-serif'] }, colors: { primary: '#16325B', secondary: '#22577A', background: '#F4F7F9', textmain: '#1F2937', textmuted: '#6B7280', danger: '#C62828', success: '#10B981' } } }
        }
    </script>
    <style>
        ::-webkit-scrollbar { width: 6px; }
        ::-webkit-scrollbar-track { background: transparent; }
        ::-webkit-scrollbar-thumb { background: #CBD5E1; border-radius: 10px; }
        ::-webkit-scrollbar-thumb:hover { background: #94A3B8; }
    </style>
</head>
<body class="antialiased overflow-hidden h-screen w-full flex bg-background">

    <aside class="w-64 bg-[#E3F0F8] flex flex-col h-full z-20 relative border-r border-gray-200 shrink-0">
        <div class="p-6">
            <h2 class="text-2xl font-bold text-primary tracking-tight">CampuSpace</h2>
            <p class="text-[10px] text-textmuted mt-1 uppercase tracking-wider">Portal Peminjaman Fasilitas</p>
        </div>
        <nav class="flex-1 p-4 space-y-2 overflow-y-auto">
            <a href="<%= request.getContextPath() %>/user/beranda.jsp" class="flex items-center gap-3 px-4 py-3 text-sm font-semibold text-primary bg-[#D6E8F5] rounded-xl transition"><i data-lucide="layout-dashboard" class="w-5 h-5"></i><span>Beranda</span></a>
            <a href="<%= request.getContextPath() %>/user/katalog.jsp" class="flex items-center gap-3 px-4 py-3 text-sm text-textmuted rounded-xl hover:bg-gray-100 transition"><i data-lucide="search" class="w-5 h-5"></i><span>Cari Fasilitas</span></a>
            <a href="<%= request.getContextPath() %>/user/peminjamanku.jsp" class="flex items-center gap-3 px-4 py-3 text-sm text-textmuted rounded-xl hover:bg-gray-100 transition"><i data-lucide="calendar-days" class="w-5 h-5"></i><span>Jadwal Peminjamanku</span></a>
            <a href="<%= request.getContextPath() %>/user/pengaturan.jsp" class="flex items-center gap-3 px-4 py-3 text-sm text-textmuted rounded-xl hover:bg-gray-100 transition"><i data-lucide="settings" class="w-5 h-5"></i><span>Pengaturan Akun</span></a>
            <div class="pt-4 mt-2">
                <a href="<%= request.getContextPath() %>/user/reservasi.jsp" class="bg-primary text-white flex items-center justify-center gap-2 px-4 py-3 text-sm font-semibold rounded-xl hover:bg-secondary transition shadow-md w-full"><i data-lucide="plus" class="w-4 h-4"></i>Ajukan Peminjaman</a>
            </div>
        </nav>
        <div class="p-4 space-y-2 border-t border-gray-200">
            <a href="<%= request.getContextPath() %>/login.jsp" class="w-full flex items-center gap-3 px-4 py-2.5 text-sm font-medium text-white bg-danger rounded-xl hover:bg-red-700 transition shadow-sm"><i data-lucide="log-out" class="w-4 h-4"></i><span>Keluar</span></a>
        </div>
    </aside>

    <main class="flex-1 flex flex-col h-full overflow-hidden bg-[#FAFAFA] rounded-tl-3xl shadow-[-10px_0_15px_rgba(0,0,0,0.03)] z-10">
        <header class="h-20 bg-white border-b border-gray-100 flex items-center justify-between px-8 z-10 shrink-0">
            <h3 class="text-xl font-bold text-primary">Beranda</h3>
            <div class="flex items-center gap-5">
                <div class="relative hidden md:block">
                    <i data-lucide="search" class="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4"></i>
                    <input type="text" placeholder="Cari Sesuatu?" class="pl-9 pr-4 py-2 border border-gray-200 rounded-xl text-sm focus:outline-none focus:border-primary w-64 bg-gray-50">
                </div>
                <button class="text-gray-500 hover:text-primary relative p-1">
                    <i data-lucide="bell" class="w-5 h-5"></i>
                    <span class="absolute top-1 right-1 w-2 h-2 bg-danger rounded-full border-2 border-white"></span>
                </button>
                <div class="w-9 h-9 rounded-full border border-gray-200 overflow-hidden cursor-pointer shadow-sm">
                    <img src="https://i.pravatar.cc/150?img=11" alt="User" class="w-full h-full object-cover">
                </div>
            </div>
        </header>

        <div class="flex-1 overflow-y-auto p-8" id="main-content-scroll">
            <div class="max-w-7xl mx-auto">
                <div class="mb-8">
                    <h1 class="text-[28px] font-bold text-primary mb-1">Selamat Datang, <%= namaUser %>!</h1>
                    <p class="text-textmuted text-sm">Kelola ruang akademik Anda dan koordinasikan jadwal penelitian Anda dengan tepat.</p>
                </div>

                <% if (dendaPengguna != null) { %>
                <div class="mb-8 bg-red-50 p-6 rounded-2xl shadow-sm border border-red-100 flex items-center justify-between gap-6">
                    <div class="flex items-center gap-4">
                        <div class="w-12 h-12 rounded-full bg-red-100 flex items-center justify-center text-danger border border-red-200"><i data-lucide="alert-triangle" class="w-6 h-6"></i></div>
                        <div>
                            <h3 class="font-bold text-danger text-base mb-0.5">Denda Tertunggak: <%= dendaPengguna.getStatusDenda() %></h3>
                            <p class="text-xs text-red-700">Peminjaman <%= dendaPengguna.getIdPeminjaman() %> pada <%= fmtTglPenuh.format(dendaPengguna.getTanggalPinjam()) %> belum diselesaikan.</p>
                        </div>
                    </div>
                    <a href="<%= request.getContextPath() %>/user/peminjamanku.jsp" class="bg-danger text-white px-5 py-2.5 rounded-xl text-xs font-semibold shadow-md flex items-center gap-2 hover:bg-red-700 transition">
                        Lihat Detail
                    </a>
                </div>
                <% } %>

                <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 items-start">
                    
                    <div class="bg-white rounded-2xl border border-gray-200 p-6 shadow-sm min-h-[380px]">
                        <div class="flex justify-between items-center mb-6">
                            <h2 class="text-[17px] font-bold text-primary">Jadwal Peminjaman</h2>
                            <a href="<%= request.getContextPath() %>/user/peminjamanku.jsp" class="text-[11px] font-semibold text-primary flex items-center gap-1 hover:underline">Lihat Jadwal <i data-lucide="external-link" class="w-3 h-3"></i></a>
                        </div>
                        <div class="space-y-4">
                            <% 
                               int countJadwal = 0;
                               if(listPeminjaman != null) {
                                   for(Peminjaman p : listPeminjaman) {
                                       if("APPROVED".equals(p.getStatusPeminjaman()) || "PENDING".equals(p.getStatusPeminjaman())) {
                                           if(countJadwal >= 3) break;
                                           String namaFas = dm.getNamaFasilitas(p.getIdFasilitas());
                                           String borderWarna = countJadwal == 0 ? "border-primary" : "border-gray-200";
                            %>
                            <div class="flex items-start gap-4 border-l-4 <%= borderWarna %> pl-4 py-1">
                                <div class="text-center shrink-0 w-12">
                                    <span class="block text-[11px] font-bold text-primary uppercase"><%= p.getTanggalPinjam() != null ? fmtBulan.format(p.getTanggalPinjam()) : "-" %></span>
                                    <span class="block text-xl font-medium text-textmain"><%= p.getTanggalPinjam() != null ? fmtTanggal.format(p.getTanggalPinjam()) : "-" %></span>
                                </div>
                                <div class="flex-1">
                                    <h3 class="text-[14px] font-bold text-textmain leading-tight"><%= namaFas %></h3>
                                    <p class="text-xs text-textmuted mt-1">10:00 WIB - 12:30 WIB</p>
                                    <p class="text-[10px] text-gray-400 mt-0.5 uppercase tracking-wide font-semibold"><%= p.getStatusPeminjaman() %></p>
                                </div>
                                <button class="text-gray-400 hover:text-primary"><i data-lucide="more-vertical" class="w-5 h-5"></i></button>
                            </div>
                            <% countJadwal++; } } } 
                               if(countJadwal == 0) {
                            %>
                            <div class="text-center py-10 text-gray-400 text-sm">Tidak ada jadwal peminjaman.</div>
                            <% } %>
                        </div>
                    </div>

                    <div class="bg-white rounded-2xl border border-gray-200 p-6 shadow-sm min-h-[380px]">
                        <h2 class="text-[17px] font-bold text-primary mb-6">Aktivitas Terkini</h2>
                        <div class="relative pl-3 border-l-[1.5px] border-gray-200 space-y-7 pb-2">
                            <% 
                               if(listAktivitas != null && !listAktivitas.isEmpty()) {
                                   int actCount = 0;
                                   for(Peminjaman a : listAktivitas) {
                                       if(actCount >= 4) break;
                                       String namaFas = dm.getNamaFasilitas(a.getIdFasilitas());
                                       String status = a.getStatusPeminjaman();
                                       
                                       String icon = "info"; String iconColor = "text-primary"; String bgIcon = "bg-[#EBF4F9]";
                                       String judulAkt = "Status Diperbarui:";
                                       String descAkt = "Reservasi " + namaFas + " Anda saat ini " + status + ".";
                                       
                                       if("APPROVED".equals(status)) { icon = "check"; iconColor = "text-primary"; judulAkt = "Reservasi Dikonfirmasi:"; descAkt = "Pengajuan " + namaFas + " telah disetujui."; }
                                       else if("REJECTED".equals(status)) { icon = "x"; iconColor = "text-danger"; bgIcon = "bg-red-50"; judulAkt = "Reservasi Ditolak:"; descAkt = "Mohon maaf, " + namaFas + " tidak dapat dipinjam."; }
                                       else if("SELESAI".equals(status)) { icon = "check-check"; iconColor = "text-gray-500"; bgIcon = "bg-gray-100"; judulAkt = "Peminjaman Selesai:"; descAkt = "Terima kasih telah meminjam " + namaFas + "."; }
                            %>
                            <div class="relative">
                                <div class="absolute -left-[23px] top-0 bg-white rounded-full p-[3px]">
                                     <div class="w-[18px] h-[18px] <%= bgIcon %> rounded-full flex items-center justify-center <%= iconColor %>"><i data-lucide="<%= icon %>" class="w-3 h-3"></i></div>
                                </div>
                                <div class="pl-4">
                                    <h4 class="text-sm font-bold text-textmain leading-tight"><%= judulAkt %></h4>
                                    <p class="text-xs text-textmuted mt-1 leading-relaxed"><%= descAkt %></p>
                                    <p class="text-[10px] text-gray-400 mt-1.5"><%= a.getTanggalPinjam() != null ? fmtTanggal.format(a.getTanggalPinjam()) + " " + fmtBulan.format(a.getTanggalPinjam()) : "Baru saja" %></p>
                                </div>
                            </div>
                            <% actCount++; } } else { %>
                            <div class="pl-4 text-xs text-gray-400">Belum ada aktivitas terekam.</div>
                            <% } %>
                            
                            <div class="relative">
                                <div class="absolute -left-[23px] top-0 bg-white rounded-full p-[3px]">
                                     <div class="w-[18px] h-[18px] bg-gray-100 rounded-full flex items-center justify-center text-gray-500"><i data-lucide="mail" class="w-3 h-3"></i></div>
                                </div>
                                <div class="pl-4">
                                    <p class="text-xs text-textmuted leading-relaxed">Anda menerima pesan dari Administrator mengenai Kebijakan Penggunaan Fasilitas.</p>
                                    <p class="text-[10px] text-gray-400 mt-1.5">Sistem</p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="bg-[#00346F] rounded-2xl p-6 shadow-md text-white flex flex-col min-h-[380px]">
                        <h2 class="text-[17px] font-bold mb-1">Fasilitas Tersedia</h2>
                        <p class="text-xs text-blue-200/80 mb-6 leading-relaxed">Reservasi langsung ruang atau peralatan yang tersedia saat ini.</p>
                        
                        <div class="space-y-3 flex-1">
                            <% if(listFasilitasTersedia != null && !listFasilitasTersedia.isEmpty()) {
                                   for(Fasilitas f : listFasilitasTersedia) { %>
                            <a href="<%= request.getContextPath() %>/user/reservasi.jsp?id=<%= f.getIdFasilitas() %>" class="flex justify-between items-center bg-white/10 hover:bg-white/20 border border-white/5 transition px-4 py-3.5 rounded-xl group cursor-pointer">
                                <span class="text-sm font-semibold tracking-wide"><%= f.getNamaFasilitas() %></span>
                                <i data-lucide="chevron-right" class="w-4 h-4 text-blue-200 group-hover:text-white transition transform group-hover:translate-x-1"></i>
                            </a>
                            <% } } else { %>
                            <div class="bg-white/10 border border-white/5 px-4 py-3 rounded-xl text-center text-xs text-blue-200">
                                Sedang memuat ketersediaan...
                            </div>
                            <% } %>
                        </div>
                        
                        <a href="<%= request.getContextPath() %>/user/katalog.jsp" class="mt-6 w-full text-center bg-white text-primary text-sm font-bold py-3.5 rounded-xl hover:bg-gray-100 transition shadow-sm">
                            Reservasi Sekarang
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </main>
    <script>lucide.createIcons({ attrs: { 'stroke-width': 1.5 } });</script>
</body>
</html>