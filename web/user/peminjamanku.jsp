<%-- 
    Document   : peminjamanku
    Created on : 29 May 2026
    Author     : Kemal Farouq
--%>

<%-- 
    Document   : peminjamanku
    Created on : 29 May 2026
    Author     : Kemal Farouq
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Date"%>
<%@page import="java.util.Calendar"%>
<%@page import="java.util.GregorianCalendar"%>
<%@page import="models.Peminjaman"%>
<%@page import="controllers.DataManager"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.text.NumberFormat"%>
<%@page import="java.util.Locale"%>
<%
    String idUser = (String) session.getAttribute("idPengguna");
    if(idUser == null) {
        response.sendRedirect("../login.jsp");
        return;
    }

    DataManager dm = new DataManager();
    dm.cekDanUpdateDendaOtomatis();
    
    List<Peminjaman> listPinjam = dm.getPeminjamanByPengguna(idUser);
   
    
    // =========================================================================
    // OPTIMASI PERFORMA: MENGHINDARI N+1 QUERY (CACHE NAMA FASILITAS)
    // =========================================================================
    Map<String, String> cacheNamaFasilitas = new HashMap<>();
    if (listPinjam != null && !listPinjam.isEmpty()) {
        for (Peminjaman p : listPinjam) {
            if (!cacheNamaFasilitas.containsKey(p.getIdFasilitas())) {
                cacheNamaFasilitas.put(p.getIdFasilitas(), dm.getNamaFasilitas(p.getIdFasilitas()));
            }
        }
    }
    // =========================================================================

    SimpleDateFormat formatTanggal = new SimpleDateFormat("dd MMM yyyy");
    NumberFormat formatRupiah = NumberFormat.getCurrencyInstance(new Locale("id", "ID"));
    
    boolean adaDenda = false;
    boolean adaVerifikasi = false;
    long totalTagihanDenda = 0;
    String idPinjamTerlambat = ""; 
    String idPinjamVerifikasi = "";
    Date hariIni = new Date(); 

    Calendar cal = new GregorianCalendar();
    int currentMonth = cal.get(Calendar.MONTH); 
    int currentYear = cal.get(Calendar.YEAR);

    String reqMonth = request.getParameter("month");
    String reqYear = request.getParameter("year");

    int displayMonth = (reqMonth != null && !reqMonth.isEmpty()) ? Integer.parseInt(reqMonth) : currentMonth;
    int displayYear = (reqYear != null && !reqYear.isEmpty()) ? Integer.parseInt(reqYear) : currentYear;

    cal.set(Calendar.YEAR, displayYear);
    cal.set(Calendar.MONTH, displayMonth);
    cal.set(Calendar.DAY_OF_MONTH, 1);

    int daysInMonth = cal.getActualMaximum(Calendar.DAY_OF_MONTH);
    int firstDayOfWeek = cal.get(Calendar.DAY_OF_WEEK); 
    int offset = firstDayOfWeek - 1; 

    String[] monthNames = {"Januari", "Februari", "Maret", "April", "Mei", "Juni", "Juli", "Agustus", "September", "Oktober", "November", "Desember"};
    
    Date lastBorrowedDate = null;
    String lastBorrowedFacility = "-";
    if (listPinjam != null && !listPinjam.isEmpty()) {
        for(Peminjaman p : listPinjam) {
            if (p.getTanggalPinjam() != null) {
                if (lastBorrowedDate == null || p.getTanggalPinjam().after(lastBorrowedDate)) {
                    lastBorrowedDate = p.getTanggalPinjam();
                    lastBorrowedFacility = cacheNamaFasilitas.get(p.getIdFasilitas()); // Menggunakan Cache
                }
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Peminjamanku - CampuSpace</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
    <script>
        tailwind.config = {
            theme: { extend: { fontFamily: { sans: ['Poppins', 'sans-serif'] }, colors: { primary: '#16325B', secondary: '#22577A', background: '#F4F7F9', textmain: '#1F2937', textmuted: '#6B7280', danger: '#C62828', success: '#10B981', warning: '#F59E0B' } } }
        }
    </script>
    <style>
        .calendar-grid { display: grid; grid-template-columns: repeat(7, minmax(0, 1fr)); gap: 1px; background-color: #e5e7eb; border: 1px solid #e5e7eb; }
        .calendar-cell { background-color: white; min-height: 110px; padding: 8px; display: flex; flex-direction: column; }
        .calendar-cell.empty { background-color: #f9fafb; }
        .event-container { display: flex; flex-direction: column; gap: 4px; flex-grow: 1; overflow-y: auto; }
        .event-container::-webkit-scrollbar { width: 3px; }
        .event-container::-webkit-scrollbar-thumb { background-color: #cbd5e1; border-radius: 10px; }
        
        .custom-scrollbar::-webkit-scrollbar { width: 4px; }
        .custom-scrollbar::-webkit-scrollbar-track { background: transparent; }
        .custom-scrollbar::-webkit-scrollbar-thumb { background: #E2E8F0; border-radius: 10px; }
        .custom-scrollbar::-webkit-scrollbar-thumb:hover { background: #CBD5E1; }
    </style>
</head>
<body class="antialiased overflow-hidden h-screen w-full flex bg-background relative">

    <div id="toast-notification" class="absolute top-6 left-1/2 transform -translate-x-1/2 z-50 transition-all duration-500 opacity-0 -translate-y-10 pointer-events-none flex items-center gap-3 bg-white px-6 py-3.5 rounded-full shadow-2xl border border-gray-100">
        <div id="toast-icon-container" class="w-8 h-8 rounded-full bg-green-100 text-success flex items-center justify-center"><i id="toast-icon" data-lucide="check" class="w-5 h-5"></i></div>
        <p class="text-sm font-semibold text-textmain" id="toast-message">Notifikasi</p>
    </div>

    <aside class="w-64 bg-[#E3F0F8] flex flex-col h-full z-20 relative border-r border-gray-200 shrink-0">
        <div class="p-6">
            <h2 class="text-2xl font-bold text-primary tracking-tight">CampuSpace</h2>
            <p class="text-[10px] text-textmuted mt-1 uppercase tracking-wider">Portal Peminjaman Fasilitas</p>
        </div>
        <nav class="flex-1 p-4 space-y-2 overflow-y-auto">
            <a href="<%= request.getContextPath() %>/user/beranda.jsp" class="flex items-center gap-3 px-4 py-3 text-sm text-textmuted rounded-xl hover:bg-gray-100 transition"><i data-lucide="layout-dashboard" class="w-5 h-5"></i><span>Beranda</span></a>
            <a href="<%= request.getContextPath() %>/user/katalog.jsp" class="flex items-center gap-3 px-4 py-3 text-sm text-textmuted rounded-xl hover:bg-gray-100 transition"><i data-lucide="search" class="w-5 h-5"></i><span>Cari Fasilitas</span></a>
            
            <a href="<%= request.getContextPath() %>/user/peminjamanku.jsp" class="flex items-center gap-3 px-4 py-3 text-sm font-semibold text-primary bg-[#D6E8F5] rounded-xl transition"><i data-lucide="calendar-days" class="w-5 h-5"></i><span>Jadwal Peminjamanku</span></a>
            
            <a href="<%= request.getContextPath() %>/user/pengaturan.jsp" class="flex items-center gap-3 px-4 py-3 text-sm text-textmuted rounded-xl hover:bg-gray-100 transition"><i data-lucide="settings" class="w-5 h-5"></i><span>Pengaturan Akun</span></a>
            
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
            <h3 class="text-xl font-bold text-primary">Jadwal Peminjamanku</h3>
            <div class="flex items-center gap-6">
                <div class="relative hidden md:block">
                    <i data-lucide="search" class="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 w-4 h-4"></i>
                    <input type="text" placeholder="Cari sesuatu?" class="pl-9 pr-4 py-2 bg-gray-50 border border-gray-200 rounded-xl text-sm outline-none focus:border-primary transition-all">
                </div>
                <button class="text-gray-500 hover:text-primary relative p-1">
                    <i data-lucide="bell" class="w-5 h-5"></i>
                </button>
                <div class="w-10 h-10 rounded-full border-2 border-gray-200 overflow-hidden shadow-sm">
                    <img src="https://i.pravatar.cc/150?img=11" alt="User" class="w-full h-full object-cover">
                </div>
            </div>
        </header>

        <div class="flex-1 overflow-y-auto p-8 relative">
            <div id="alert-denda-container"></div>

            <div class="mb-6 flex flex-col sm:flex-row justify-between items-start sm:items-end gap-4">
                <div>
                    <h1 class="text-3xl font-bold text-primary mb-2">Jadwal Peminjaman Anda</h1>
                    <div class="flex items-center gap-2 text-sm text-textmuted">
                        <i data-lucide="history" class="w-4 h-4"></i>
                        <span>Terakhir meminjam: <strong><%= lastBorrowedFacility %></strong> 
                            (<%= lastBorrowedDate != null ? formatTanggal.format(lastBorrowedDate) : "Belum ada riwayat" %>)
                        </span>
                    </div>
                </div>
                
                <form action="peminjamanku.jsp" method="GET" class="flex gap-2 bg-white p-1 rounded-lg border border-gray-200 shadow-sm">
                    <select name="month" class="px-3 py-1.5 text-sm bg-background text-primary rounded-md shadow-sm outline-none font-semibold cursor-pointer" onchange="this.form.submit()">
                        <% for(int m=0; m<12; m++) { %>
                            <option value="<%= m %>" <%= displayMonth == m ? "selected" : "" %>><%= monthNames[m] %></option>
                        <% } %>
                    </select>
                    <select name="year" class="px-3 py-1.5 text-sm bg-background text-primary rounded-md shadow-sm outline-none font-semibold cursor-pointer" onchange="this.form.submit()">
                        <% for(int y = currentYear - 1; y <= currentYear + 1; y++) { %>
                            <option value="<%= y %>" <%= displayYear == y ? "selected" : "" %>><%= y %></option>
                        <% } %>
                    </select>
                </form>
            </div>

            <div class="grid grid-cols-1 grid-cols-1 xl:grid-cols-3 gap-6">
                <div class="xl:col-span-2 bg-white rounded-2xl shadow-card border border-gray-100 overflow-hidden h-fit">
                    <div class="grid grid-cols-7 text-center bg-gray-50 border-b border-gray-200 text-xs font-semibold text-gray-500">
                        <div class="py-3 border-r border-gray-200">MIN</div><div class="py-3 border-r border-gray-200">SEN</div><div class="py-3 border-r border-gray-200">SEL</div><div class="py-3 border-r border-gray-200">RAB</div><div class="py-3 border-r border-gray-200">KAM</div><div class="py-3 border-r border-gray-200">JUM</div><div class="py-3">SAB</div>
                    </div>
                    
                    <div class="calendar-grid">
                        <% for(int i = 0; i < offset; i++) { %> <div class="calendar-cell empty"></div> <% } %>

                        <% 
                            Calendar todayCal = Calendar.getInstance();
                            int tYear = todayCal.get(Calendar.YEAR);
                            int tMonth = todayCal.get(Calendar.MONTH);
                            int tDay = todayCal.get(Calendar.DAY_OF_MONTH);
                            
                            for(int i = 1; i <= daysInMonth; i++) { 
                               StringBuilder eventsHtml = new StringBuilder();
                               if (listPinjam != null) {
                                   for(Peminjaman p : listPinjam) {
                                       if ("APPROVED".equals(p.getStatusPeminjaman())) {
                                           String namaFasilitas = cacheNamaFasilitas.get(p.getIdFasilitas()); // Menggunakan Cache
                                           if (p.getTanggalPinjam() != null) {
                                               Calendar pinjamCal = new GregorianCalendar(); pinjamCal.setTime(p.getTanggalPinjam());
                                               if (pinjamCal.get(Calendar.YEAR) == displayYear && pinjamCal.get(Calendar.MONTH) == displayMonth && pinjamCal.get(Calendar.DAY_OF_MONTH) == i) {
                                                   eventsHtml.append("<div class=\"bg-blue-100 border border-blue-200 text-primary p-1.5 rounded-md text-[9px] font-semibold leading-tight shadow-sm\">").append(namaFasilitas).append("<div class=\"text-[8px] font-medium text-gray-500 mt-1\">Direservasi</div></div>");
                                               }
                                           }
                                           if (p.getTanggalKembali() != null) {
                                               Calendar kembaliCal = new GregorianCalendar(); kembaliCal.setTime(p.getTanggalKembali());
                                               if (kembaliCal.get(Calendar.YEAR) == displayYear && kembaliCal.get(Calendar.MONTH) == displayMonth && kembaliCal.get(Calendar.DAY_OF_MONTH) == i) {
                                                   if(!"MENUNGGU_VERIFIKASI".equals(p.getStatusDenda())) {
                                                       eventsHtml.append("<div class=\"bg-red-50 border border-red-200 text-danger p-1.5 rounded-md text-[9px] font-semibold leading-tight shadow-sm\">").append(namaFasilitas).append("<div class=\"text-[8px] font-medium text-red-400 mt-0.5 flex items-center gap-1\"><i data-lucide=\"alert-circle\" class=\"w-2.5 h-2.5\"></i> Batas Kembali</div></div>");
                                                   }
                                               }
                                           }
                                       }
                                   }
                               }
                               
                               boolean isToday = (displayYear == tYear && displayMonth == tMonth && i == tDay);
                               
                               if(eventsHtml.length() > 0) { 
                        %>
                                <div class="calendar-cell <%= isToday ? "ring-2 ring-inset ring-primary bg-blue-50/30" : "bg-slate-50/50" %>">
                                    <div class="flex items-start justify-between mb-2">
                                        <div class="w-6 h-6 flex shrink-0 items-center justify-center bg-primary text-white rounded-full text-xs font-semibold"><%= i %></div>
                                        <% if(isToday) { %><div class="flex items-center gap-1 text-[9px] font-bold text-primary bg-blue-100 px-1.5 py-0.5 rounded-md shadow-sm"><i data-lucide="map-pin" class="w-3 h-3 fill-primary"></i> HARI INI</div><% } %>
                                    </div>
                                    <div class="event-container"><%= eventsHtml.toString() %></div>
                                </div>
                        <% } else { %>
                                <div class="calendar-cell <%= isToday ? "ring-2 ring-inset ring-primary bg-blue-50/30" : "" %>">
                                    <div class="flex items-start justify-between">
                                        <span class="text-xs font-semibold <%= isToday ? "text-primary" : "text-gray-800" %>"><%= i %></span>
                                        <% if(isToday) { %><div class="flex items-center gap-1 text-[9px] font-bold text-primary bg-blue-100 px-1.5 py-0.5 rounded-md shadow-sm"><i data-lucide="map-pin" class="w-3 h-3 fill-primary"></i> HARI INI</div><% } %>
                                    </div>
                                </div>
                        <% } } %>
                    </div>
                </div>

                <div class="space-y-6">
                    
                    <div class="bg-white rounded-2xl shadow-card border border-gray-100 p-6 flex flex-col" style="max-h: 520px;">
                        <div class="flex justify-between items-center mb-4 pb-3 border-b border-gray-100">
                            <h3 class="font-semibold text-textmain flex items-center gap-2">
                                <i data-lucide="layout-list" class="w-4 h-4 text-primary"></i> Status Fasilitas
                            </h3>
                            <div class="relative">
                                <select id="filterStatus" onchange="filterStatusFasilitas()" class="appearance-none bg-gray-50 border border-gray-200 text-textmain text-[11px] rounded-lg pl-3 pr-7 py-1.5 focus:outline-none focus:border-primary cursor-pointer font-semibold shadow-sm transition-all">
                                    <option value="SEMUA">Semua Status</option>
                                    <option value="AKTIF">Sedang Aktif</option>
                                    <option value="RIWAYAT">Riwayat (Selesai/Batal)</option>
                                </select>
                                <i data-lucide="chevron-down" class="w-3 h-3 absolute right-2.5 top-1/2 transform -translate-y-1/2 text-gray-500 pointer-events-none"></i>
                            </div>
                        </div>
                        
                        <div class="space-y-3 overflow-y-auto pr-1 flex-1 custom-scrollbar" id="statusListContainer">
                            <% 
                                if (listPinjam != null && !listPinjam.isEmpty()) {
                                    for(Peminjaman p : listPinjam) {
                                        String namaFasilitas = cacheNamaFasilitas.get(p.getIdFasilitas()); // Menggunakan Cache
                                        String statusDB = p.getStatusPeminjaman();
                                        String statusDendaDB = p.getStatusDenda(); 
                                        
                                        String badgeWarna = "bg-orange-100 text-warning"; 
                                        String badgeTeks = "Menunggu";
                                        String kategoriFilter = "AKTIF";
                                        
                                        if ("APPROVED".equals(statusDB) || "DENDA".equals(statusDB) || "DIKEMBALIKAN".equals(statusDB)) {
                                            Date batasKembali = p.getTanggalKembali();
                                            
                                            if (batasKembali != null && hariIni.after(batasKembali) && !formatTanggal.format(hariIni).equals(formatTanggal.format(batasKembali))) {
                                                if ("MENUNGGU_VERIFIKASI".equals(statusDendaDB)) {
                                                    badgeWarna = "bg-blue-100 text-primary"; badgeTeks = "Verifikasi"; adaVerifikasi = true; idPinjamVerifikasi = p.getIdPeminjaman();
                                                    kategoriFilter = "AKTIF";
                                                } else if (!"LUNAS".equals(statusDendaDB)) {
                                                    long selisihHari = (hariIni.getTime() - batasKembali.getTime()) / (1000 * 60 * 60 * 24);
                                                    long denda = selisihHari * 50000; 
                                                    adaDenda = true; totalTagihanDenda += denda; idPinjamTerlambat = p.getIdPeminjaman(); 
                                                    badgeWarna = "bg-red-100 text-danger animate-pulse"; badgeTeks = "Terlambat";
                                                    kategoriFilter = "AKTIF";
                                                } else {
                                                    if ("DIKEMBALIKAN".equals(statusDB)) { badgeWarna = "bg-blue-100 text-primary"; badgeTeks = "Proses Kembali"; }
                                                    else { badgeWarna = "bg-green-100 text-success"; badgeTeks = "Dipinjam"; }
                                                    kategoriFilter = "AKTIF";
                                                }
                                            } else { 
                                                if ("DIKEMBALIKAN".equals(statusDB)) { badgeWarna = "bg-blue-100 text-primary"; badgeTeks = "Proses Kembali"; }
                                                else { badgeWarna = "bg-green-100 text-success"; badgeTeks = "Dipinjam"; }
                                                kategoriFilter = "AKTIF";
                                            }
                                        } else if ("REJECTED".equals(statusDB)) { 
                                            badgeWarna = "bg-red-100 text-danger"; badgeTeks = "Ditolak"; 
                                            kategoriFilter = "RIWAYAT";
                                        } else if ("SELESAI".equals(statusDB)) { 
                                            badgeWarna = "bg-gray-100 text-gray-500"; badgeTeks = "Selesai"; 
                                            kategoriFilter = "RIWAYAT";
                                        }
                            %>
                                <div class="status-item flex items-center gap-3 transition-all duration-300" data-kategori="<%= kategoriFilter %>">
                                    <div class="flex-1 border border-gray-200 rounded-xl p-3 flex flex-col bg-gray-50 hover:bg-white hover:shadow-sm hover:border-gray-300 transition-all relative overflow-hidden group">
                                        <% if(badgeTeks.equals("Terlambat")) { %> <div class="absolute left-0 top-0 bottom-0 w-1 bg-danger"></div> <% } %>
                                        <% if(badgeTeks.equals("Dipinjam")) { %> <div class="absolute left-0 top-0 bottom-0 w-1 bg-success"></div> <% } %>
                                        
                                        <div class="flex justify-between items-center w-full">
                                            <div>
                                                <span class="text-xs font-bold text-textmain block truncate w-36 group-hover:text-primary transition-colors"><%= namaFasilitas %></span>
                                                <span class="text-[9px] text-gray-500 block mt-0.5 flex items-center gap-1">
                                                    <i data-lucide="clock" class="w-2.5 h-2.5"></i> Batas: <%= p.getTanggalKembali() != null ? formatTanggal.format(p.getTanggalKembali()) : "-" %>
                                                </span>
                                            </div>
                                            <span class="text-[9px] font-bold <%= badgeWarna %> px-2.5 py-1 rounded-md uppercase tracking-widest shadow-sm"><%= badgeTeks %></span>
                                        </div>

                                        <% if ("APPROVED".equals(statusDB) || "DENDA".equals(statusDB)) { %>
                                            <form action="../PengembalianServlet" method="POST" class="mt-2.5 w-full" onsubmit="return confirm('Apakah Anda yakin sudah membersihkan dan mengembalikan fasilitas ini kepada Admin?');">
                                                <input type="hidden" name="id_peminjaman" value="<%= p.getIdPeminjaman() %>">
                                                <button type="submit" class="w-full py-1.5 bg-white border border-gray-200 text-primary hover:bg-gray-100 text-[10px] font-bold rounded-lg transition-all flex items-center justify-center gap-1.5 shadow-sm">
                                                    <i data-lucide="check-circle" class="w-3.5 h-3.5 text-primary"></i> Saya Sudah Mengembalikan Ini
                                                </button>
                                            </form>
                                        <% } %>
                                    </div>
                                </div>
                            <%      } 
                                } else { 
                            %>
                                <div class="text-center py-8">
                                    <i data-lucide="inbox" class="w-8 h-8 text-gray-300 mx-auto mb-2"></i>
                                    <p class="text-xs text-gray-400 font-medium">Belum ada aktivitas.</p>
                                </div>
                            <%  } %>
                        </div>
                    </div>

                    <% if(adaVerifikasi) { %>
                    <div class="bg-blue-50 rounded-2xl shadow-card border border-blue-200 p-6 relative overflow-hidden">
                        <div class="absolute -right-4 -top-4 opacity-10 text-primary"><i data-lucide="shield-check" class="w-32 h-32"></i></div>
                        <div class="relative z-10">
                            <div class="flex items-center gap-2 text-primary mb-2">
                                <i data-lucide="info" class="w-5 h-5 animate-pulse"></i>
                                <h3 class="font-bold">Menunggu Konfirmasi</h3>
                            </div>
                            <p class="text-xs text-blue-800 mb-4 leading-relaxed">Bukti pembayaran Anda untuk ID <span class="font-mono font-bold"><%= idPinjamVerifikasi %></span> sedang diperiksa Admin.</p>
                        </div>
                    </div>
                    <% } %>

                    <% if(adaDenda) { %>
                    <div class="bg-red-50 rounded-2xl shadow-card border border-red-200 p-6 relative overflow-hidden">
                        <div class="absolute -right-4 -top-4 opacity-10 text-danger"><i data-lucide="alert-triangle" class="w-32 h-32"></i></div>
                        <div class="relative z-10">
                            <div class="flex items-center gap-2 text-danger mb-2">
                                <i data-lucide="alert-circle" class="w-5 h-5"></i><h3 class="font-bold">Tagihan iDenda</h3>
                            </div>
                            <p class="text-xs text-red-800 mb-4 leading-relaxed">Sistem mendeteksi keterlambatan pengembalian fasilitas. Silakan lunasi denda untuk mengembalikan akses peminjaman Anda.</p>
                            
                            <div class="bg-white rounded-xl p-4 border border-red-100 shadow-sm mb-4">
                                <p class="text-[10px] text-gray-500 font-semibold uppercase tracking-wider mb-1">Total Denda</p>
                                <h2 class="text-2xl font-bold text-danger"><%= formatRupiah.format(totalTagihanDenda) %></h2>
                            </div>

                            <form action="../UploadResiServlet" method="POST" enctype="multipart/form-data" class="mt-5 pt-4 border-t border-red-100/50">
                                <input type="hidden" name="id_peminjaman" value="<%= idPinjamTerlambat %>">
                                <div class="relative border-2 border-dashed border-red-200 bg-white/50 rounded-xl p-5 text-center hover:bg-red-50 hover:border-red-300 transition cursor-pointer group">
                                    <input type="file" name="foto_resi" accept="image/*" required class="absolute inset-0 w-full h-full opacity-0 cursor-pointer z-10" id="fileInput-<%= idPinjamTerlambat %>" onchange="previewFileName(this)">
                                    <div class="flex flex-col items-center justify-center group-hover:scale-105 transition-transform duration-300">
                                        <div class="w-10 h-10 bg-red-100 text-danger rounded-full flex items-center justify-center mb-2"><i data-lucide="image-plus" class="w-5 h-5"></i></div>
                                        <p class="text-xs font-semibold text-danger mb-0.5" id="fileName-<%= idPinjamTerlambat %>">Klik atau Seret Bukti Transfer</p>
                                    </div>
                                </div>
                                <button type="submit" class="w-full mt-3 bg-danger text-white py-3 rounded-xl text-sm font-semibold hover:bg-red-800 transition shadow-md flex items-center justify-center gap-2">Kirim Bukti <i data-lucide="send" class="w-4 h-4"></i></button>
                            </form>
                        </div>
                    </div>
                    <% } %>

                    <% if(!adaDenda && !adaVerifikasi) { %>
                    <div class="bg-white rounded-2xl shadow-card border border-gray-100 p-6">
                        <h3 class="font-semibold text-textmain mb-4">Pengingat Pengembalian</h3>
                        <% 
                            boolean hasDeadline = false;
                            if (listPinjam != null && !listPinjam.isEmpty()) {
                                for(Peminjaman p : listPinjam) {
                                    if("APPROVED".equals(p.getStatusPeminjaman()) && !"MENUNGGU_VERIFIKASI".equals(p.getStatusDenda())) {
                                        hasDeadline = true;
                                        String namaFasilitas = cacheNamaFasilitas.get(p.getIdFasilitas()); // Menggunakan Cache
                        %>
                                <div class="border border-gray-200 rounded-xl p-4 relative bg-white mb-3 shadow-sm">
                                    <div class="w-10 h-10 bg-blue-50 text-primary rounded-lg flex items-center justify-center mb-3"><i data-lucide="clock" class="w-5 h-5"></i></div>
                                    <h4 class="font-semibold text-sm text-textmain"><%= namaFasilitas %></h4>
                                    <p class="text-xs text-textmuted mb-2">Harap dikembalikan pada:</p>
                                    <div class="flex items-center gap-1.5 text-[11px] text-danger font-semibold mt-2"><i data-lucide="calendar" class="w-3.5 h-3.5"></i> <%= p.getTanggalKembali() != null ? formatTanggal.format(p.getTanggalKembali()) : "-" %></div>
                                </div>
                        <%      }
                                }
                            } 
                            if(!hasDeadline) { 
                        %>
                            <p class="text-xs text-gray-400">Tidak ada tanggungan fasilitas aktif saat ini.</p>
                        <%  } %>
                    </div>
                    <% } %>
                    
                </div>
            </div>
        </div>
    </main>

    <script> lucide.createIcons({ attrs: { 'stroke-width': 1.5 } }); </script>
    <script>
        function previewFileName(input) {
            const id = input.id.replace('fileInput-', '');
            const fileNameEl = document.getElementById('fileName-' + id);
            if(input.files && input.files[0]) {
                fileNameEl.innerText = input.files[0].name;
                fileNameEl.classList.remove('text-danger');
                fileNameEl.classList.add('text-success'); 
            }
        }

        function filterStatusFasilitas() {
            const selectedKategori = document.getElementById('filterStatus').value;
            const items = document.querySelectorAll('.status-item');

            items.forEach(item => {
                const itemKategori = item.getAttribute('data-kategori');
                if (selectedKategori === 'SEMUA' || selectedKategori === itemKategori) {
                    item.style.display = 'flex';
                } else {
                    item.style.display = 'none';
                }
            });
        }

        const urlParamsKembali = new URLSearchParams(window.location.search);
        const statusParam = urlParamsKembali.get('status');
        
        if (statusParam) {
            const toast = document.getElementById('toast-notification');
            const msg = document.getElementById('toast-message');
            const iconCont = document.getElementById('toast-icon-container');
            const icon = document.getElementById('toast-icon');
            
            if (statusParam === 'sukses_kembali') {
                msg.innerText = "Konfirmasi pengembalian berhasil dikirim!";
                iconCont.className = "w-8 h-8 rounded-full bg-green-100 text-success flex items-center justify-center";
                icon.setAttribute('data-lucide', 'check');
                
                toast.classList.remove('opacity-0', '-translate-y-10', 'pointer-events-none');
                toast.classList.add('opacity-100', 'translate-y-0');
                
                setTimeout(() => {
                    toast.classList.remove('opacity-100', 'translate-y-0');
                    toast.classList.add('opacity-0', '-translate-y-10', 'pointer-events-none');
                }, 4000);
                
                window.history.replaceState({}, document.title, window.location.pathname);
            } else if (statusParam === 'error_sistem') {
                msg.innerText = "Gagal memproses konfirmasi pengembalian.";
                iconCont.className = "w-8 h-8 rounded-full bg-red-100 text-danger flex items-center justify-center";
                icon.setAttribute('data-lucide', 'x-circle');
                
                toast.classList.remove('opacity-0', '-translate-y-10', 'pointer-events-none');
                toast.classList.add('opacity-100', 'translate-y-0');
                
                setTimeout(() => {
                    toast.classList.remove('opacity-100', 'translate-y-0');
                    toast.classList.add('opacity-0', '-translate-y-10', 'pointer-events-none');
                }, 4000);
                
                window.history.replaceState({}, document.title, window.location.pathname);
            }
            lucide.createIcons({ attrs: { 'stroke-width': 1.5 } });
        }
    </script>
</body>
</html>