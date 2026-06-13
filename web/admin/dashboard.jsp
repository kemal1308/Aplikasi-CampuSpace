<%-- 
    Document   : dashboard
    Created on : 30 May 2026
    Author     : Kemal Farouq
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="models.*"%>
<%@page import="controllers.DataManager"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Calendar"%>
<%@page import="java.util.GregorianCalendar"%>
<%
    if (session.getAttribute("roleAktif") == null || !session.getAttribute("roleAktif").equals("ADMIN")) {
        response.sendRedirect("../admin_login.jsp");
        return;
    }

    DataManager dm = new DataManager();
    dm.cekDanUpdateDendaOtomatis(); 

    List<Peminjaman> listPending = dm.getPendingReservasi();
    List<Peminjaman> listRiwayat = dm.getRiwayatReservasi();
    List<Peminjaman> listVerifikasi = dm.getVerifikasiDenda(); 
    List<Fasilitas> listFasilitas = dm.getAllFasilitas();
    
    SimpleDateFormat fmtTgl = new SimpleDateFormat("dd MMM yyyy");
    SimpleDateFormat fmtJam = new SimpleDateFormat("HH:mm"); // Formatter untuk Jam di Admin

    Calendar cal = new GregorianCalendar();
    int currentMonth = cal.get(Calendar.MONTH); 
    int currentYear = cal.get(Calendar.YEAR);

    String reqMonth = request.getParameter("month");
    String reqYear = request.getParameter("year");

    int displayMonth = (reqMonth != null && !reqMonth.isEmpty()) ? Integer.parseInt(reqMonth) : currentMonth;
    int displayYear = (reqYear != null && !reqYear.isEmpty()) ? Integer.parseInt(reqYear) : currentYear;

    String[] monthNames = {"Januari", "Februari", "Maret", "April", "Mei", "Juni", "Juli", "Agustus", "September", "Oktober", "November", "Desember"};

    int totalSelesaiFiltered = dm.getJumlahReservasiSelesaiTerfilter(displayMonth, displayYear);

    // --- LOGIKA MENGHITUNG OKUPANSI ---
    int totalRuangan = 0; int totalAlat = 0;
    int activeRuangan = 0; int activeAlat = 0;

    if (listFasilitas != null) {
        for(Fasilitas f : listFasilitas) {
            if(f instanceof Ruangan) totalRuangan++;
            else if(f instanceof AlatElektronik) totalAlat++;
        }
    }

    if (listRiwayat != null) {
        for(Peminjaman p : listRiwayat) {
            String status = p.getStatusPeminjaman();
            if(status != null && (status.equalsIgnoreCase("DISETUJUI") || status.equalsIgnoreCase("DIPINJAM") || status.equalsIgnoreCase("AKTIF") || status.equalsIgnoreCase("APPROVED"))) {
                if (listFasilitas != null) {
                    for(Fasilitas f : listFasilitas) {
                        if(f.getIdFasilitas().equals(p.getIdFasilitas())) {
                            if(f instanceof Ruangan) activeRuangan++;
                            else if(f instanceof AlatElektronik) activeAlat++;
                            break;
                        }
                    }
                }
            }
        }
    }

    int persenRuangan = (totalRuangan > 0) ? (activeRuangan * 100 / totalRuangan) : 0;
    int persenAlat = (totalAlat > 0) ? (activeAlat * 100 / totalAlat) : 0;
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CampuSpace Admin - Dashboard</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/@phosphor-icons/web"></script>
    <script>
        tailwind.config = {
            theme: { extend: { fontFamily: { sans: ['Poppins', 'sans-serif'], },
                colors: { primary: '#16325B', secondary: '#22577A', background: '#F4F7F9', textmain: '#1F2937', textmuted: '#6B7280', danger: '#C62828', success: '#10B981', warning: '#F59E0B' }
            }}
        }
    </script>
    <style>
        .shadow-card { box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05), 0 2px 4px -1px rgba(0, 0, 0, 0.03); }
    </style>
</head>
<body class="antialiased overflow-hidden h-screen w-full flex bg-background">
    
    <aside class="w-64 bg-[#16325B] flex flex-col h-full z-20 relative shrink-0">
        <div class="p-6">
            <h2 class="text-2xl font-bold text-white tracking-tight">CampuSpace</h2>
            <p class="text-[10px] text-blue-200 mt-1 uppercase tracking-wider">Portal Admin</p>
        </div>
        <nav class="flex-1 p-4 space-y-2 overflow-y-auto" id="sidebar-nav">
            <a href="#" onclick="switchMenu('beranda')" id="nav-beranda" class="nav-item flex items-center gap-3 px-4 py-3 text-sm font-semibold text-[#16325B] bg-white rounded-xl transition shadow-sm">
                <i class="ph-duotone ph-squares-four text-xl"></i><span>Beranda</span>
            </a>
            
            <a href="#" onclick="switchMenu('approval')" id="nav-approval" class="nav-item flex items-center justify-between px-4 py-3 text-sm text-blue-100 rounded-xl hover:bg-white/10 transition">
                <div class="flex items-center gap-3">
                    <i class="ph-duotone ph-tray text-xl"></i><span>Persetujuan</span>
                </div>
                <% if(listPending != null && listPending.size() > 0) { %>
                    <span class="bg-danger text-white text-[10px] font-bold px-2 py-0.5 rounded-full shadow-sm"><%= listPending.size() %></span>
                <% } else { %>
                    <span class="bg-white/20 text-white/70 text-[10px] font-bold px-2 py-0.5 rounded-full">0</span>
                <% } %>
            </a>
            
            <a href="#" onclick="switchMenu('fasilitas')" id="nav-fasilitas" class="nav-item flex items-center gap-3 px-4 py-3 text-sm text-blue-100 rounded-xl hover:bg-white/10 transition">
                <i class="ph-duotone ph-stack text-xl"></i><span>Kelola Fasilitas</span>
            </a>
            
            <a href="#" onclick="switchMenu('laporan')" id="nav-laporan" class="nav-item flex items-center gap-3 px-4 py-3 text-sm text-blue-100 rounded-xl hover:bg-white/10 transition">
                <i class="ph-duotone ph-pulse text-xl"></i><span>Laporan & Log</span>
            </a>
        </nav>
        <div class="p-4 space-y-2 bg-[#0F2342]">
            <a href="../admin_login.jsp" class="w-full flex items-center gap-3 px-4 py-3 text-sm font-medium text-red-400 bg-red-500/10 rounded-xl hover:bg-red-500 hover:text-white transition shadow-sm">
                <i class="ph-duotone ph-sign-out text-lg"></i><span>Keluar Sistem</span>
            </a>
        </div>
    </aside>

    <main class="flex-1 flex flex-col h-full overflow-hidden bg-[#F4FAFF] z-10">
        
        <header class="h-20 bg-white border-b border-gray-100 flex items-center justify-between px-8 z-10 shrink-0">
            <h3 id="page-title" class="text-xl font-bold text-primary">Beranda Sistem</h3>
            <div class="flex items-center gap-6">
                <div class="relative hidden md:block">
                    <i class="ph-bold ph-magnifying-glass absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 text-lg"></i>
                    <input type="text" placeholder="Cari sesuatu?" class="pl-10 pr-4 py-2 bg-gray-50 border border-gray-200 rounded-xl text-sm outline-none focus:border-primary transition-all">
                </div>
                <button class="text-gray-400 hover:text-primary relative p-1 transition">
                    <i class="ph-duotone ph-bell text-2xl"></i>
                    <% if(listPending != null && listPending.size() > 0) { %>
                        <span class="absolute top-1 right-1 w-2.5 h-2.5 bg-danger rounded-full border-2 border-white"></span>
                    <% } %>
                </button>
                <div class="flex items-center gap-3 pl-6 border-l border-gray-200">
                    <div class="text-right hidden md:block">
                        <p class="text-sm font-bold text-primary leading-tight"><%= session.getAttribute("userAktif") != null ? session.getAttribute("userAktif") : "Administrator" %></p>
                        <p class="text-[10px] text-textmuted uppercase tracking-wide">ID: <%= session.getAttribute("idPengguna") != null ? session.getAttribute("idPengguna") : "ADM-001" %></p>
                    </div>
                    <div class="w-10 h-10 rounded-full border-2 border-gray-100 shadow-sm bg-[#D6E8F5] text-primary flex items-center justify-center font-bold">
                        AP
                    </div>
                </div>
            </div>
        </header>

        <div class="flex-1 overflow-y-auto p-8 relative bg-transparent" id="main-content-scroll">
            
            <div id="content-beranda" class="content-section space-y-8">
                <div class="flex flex-col sm:flex-row justify-between items-start sm:items-end gap-4">
                    <div>
                        <h1 class="text-3xl font-bold text-primary mb-2">Beranda Sistem</h1>
                        <p class="text-textmuted text-sm">Monitoring metrik dan efektivitas penggunaan infrastruktur kampus.</p>
                    </div>
                    <form action="dashboard.jsp" method="GET" class="flex gap-2 bg-white p-1 rounded-lg border border-gray-200 shadow-sm z-10 relative">
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

                <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                    <div class="bg-gray-50 rounded-2xl p-6 border border-gray-100 shadow-sm group">
                        <div class="p-2.5 bg-white rounded-xl text-purple-600 mb-4 w-fit shadow-sm border border-gray-100"><i class="ph-duotone ph-buildings text-2xl"></i></div>
                        <p class="text-xs font-bold text-gray-400 uppercase tracking-widest">Total Fasilitas</p>
                        <h3 class="text-3xl font-bold text-textmain mt-1"><%= listFasilitas != null ? listFasilitas.size() : 0 %></h3>
                    </div>
                    <div class="bg-gray-50 rounded-2xl p-6 border border-gray-100 shadow-sm group">
                        <div class="flex justify-between items-start mb-4">
                            <div class="p-2.5 bg-white rounded-xl text-warning shadow-sm border border-gray-100"><i class="ph-duotone ph-envelope-open text-2xl"></i></div>
                            <% if(listPending != null && listPending.size() > 0) { %>
                                <span class="text-[10px] font-bold text-danger bg-red-100 border border-red-200 px-2 py-0.5 rounded-full">Butuh Aksi</span>
                            <% } %>
                        </div>
                        <p class="text-xs font-bold text-gray-400 uppercase tracking-widest">Menunggu Approval</p>
                        <h3 class="text-3xl font-bold text-textmain mt-1"><%= listPending != null ? listPending.size() : 0 %></h3>
                    </div>
                    <div class="bg-gray-50 rounded-2xl p-6 border border-gray-100 shadow-sm group">
                        <div class="p-2.5 bg-white rounded-xl text-success mb-4 w-fit shadow-sm border border-gray-100"><i class="ph-duotone ph-calendar-check text-2xl"></i></div>
                        <p class="text-xs font-bold text-gray-400 uppercase tracking-widest">Reservasi Selesai / Log</p>
                        <h3 class="text-3xl font-bold text-textmain mt-1"><%= totalSelesaiFiltered %></h3>
                    </div>
                </div>

                <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
                    <div class="lg:col-span-2 bg-white rounded-2xl border border-gray-200 shadow-sm p-6">
                        <div class="flex justify-between items-center mb-6">
                            <h3 class="font-bold text-primary flex items-center gap-2 text-lg">
                                <i class="ph-duotone ph-clock-counter-clockwise text-xl"></i> Jejaring Aktivitas Terbaru
                            </h3>
                            <button onclick="switchMenu('laporan')" class="text-xs font-semibold text-secondary hover:underline">Lihat Semua Log</button>
                        </div>
                        <div class="space-y-6 relative before:absolute before:left-[19px] before:top-2 before:bottom-2 before:w-0.5 before:bg-gray-100">
                            <div class="flex gap-4 relative">
                                <div class="w-10 h-10 rounded-full bg-green-50 text-success flex items-center justify-center shrink-0 border-4 border-white z-10"><i class="ph-bold ph-check text-base"></i></div>
                                <div>
                                    <h4 class="text-sm font-bold text-textmain">Sistem Aktif & Siap</h4>
                                    <p class="text-xs text-textmuted leading-relaxed">Administrator berhasil login. Seluruh data dari DataManager telah berhasil dimuat.</p>
                                    <span class="text-[10px] text-gray-400 mt-1 block">Baru saja</span>
                                </div>
                            </div>
                            <div class="flex gap-4 relative">
                                <div class="w-10 h-10 rounded-full bg-blue-50 text-primary flex items-center justify-center shrink-0 border-4 border-white z-10"><i class="ph-bold ph-arrows-clockwise text-base"></i></div>
                                <div>
                                    <h4 class="text-sm font-bold text-textmain">Sinkronisasi Database</h4>
                                    <p class="text-xs text-textmuted leading-relaxed">Terdapat <%= listPending != null ? listPending.size() : 0 %> antrean persetujuan and <%= listFasilitas != null ? listFasilitas.size() : 0 %> fasilitas terdaftar.</p>
                                    <span class="text-[10px] text-gray-400 mt-1 block">Log Otomatis</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="bg-[#00346F] rounded-2xl border border-gray-200 shadow-sm p-6">
                        <h3 class="font-bold text-white flex items-center gap-2 mb-6 text-lg">
                            <i class="ph-duotone ph-chart-bar text-xl"></i> Monitoring Peminjaman
                        </h3>
                        <div class="space-y-6">
                            <div>
                                <div class="flex justify-between text-xs font-bold mb-2">
                                    <span class="text-white">Ruang Kelas / Gedung</span>
                                    <span class="text-white"><%= persenRuangan %>%</span>
                                </div>
                                <div class="w-full h-2 bg-gray-200 rounded-full overflow-hidden">
                                    <div class="h-full bg-[#28A17B] transition-all duration-1000" style="width: <%= persenRuangan %>%"></div>
                                </div>
                            </div>
                            <div>
                                <div class="flex justify-between text-xs font-bold mb-2">
                                    <span class="text-white">Alat Elektronik</span>
                                    <span class="text-white"><%= persenAlat %>%</span>
                                </div>
                                <div class="w-full h-2 bg-gray-200 rounded-full overflow-hidden">
                                    <div class="h-full bg-[#28A17B] transition-all duration-1000" style="width: <%= persenAlat %>%"></div>
                                </div>
                            </div>
                        </div>
                        <div class="mt-8 p-4 bg-white rounded-xl border border-dashed border-gray-300">
                            <p class="text-[11px] text-textmuted text-center italic leading-relaxed">
                                "Persentase yang dihitung secara langsung berdasarkan total fasilitas dan peminjaman yang berstatus aktif."
                            </p>
                        </div>
                    </div>
                </div>
            </div>

            <div id="content-approval" class="content-section space-y-6 hidden">
                <div class="mb-6">
                    <h1 class="text-2xl font-bold text-primary mb-1">Tinjauan Pengajuan</h1>
                    <p class="text-textmuted text-sm">Verifikasi permintaan peminjaman fasilitas dari mahasiswa dan dosen.</p>
                </div>
                
                <div class="bg-white rounded-2xl border border-gray-200 overflow-hidden flex flex-col shadow-sm">
                    <div class="overflow-x-auto">
                        <table class="w-full text-left border-collapse">
                            <thead>
                                <tr class="bg-gray-50 border-b border-gray-200 text-xs text-textmuted uppercase tracking-wider">
                                    <th class="p-4 font-semibold">ID Reservasi</th>
                                    <th class="p-4 font-semibold">ID Pemohon</th>
                                    <th class="p-4 font-semibold">Fasilitas</th>
                                    <th class="p-4 font-semibold">Keperluan</th>
                                    <th class="p-4 font-semibold">Jadwal Pinjam</th>
                                    <th class="p-4 font-semibold text-center">Aksi</th>
                                </tr>
                            </thead>
                            <tbody class="text-sm divide-y divide-gray-100">
                                <% if(listPending != null && !listPending.isEmpty()) {
                                       for(Peminjaman p : listPending) { 
                                           String namaFasilitas = dm.getNamaFasilitas(p.getIdFasilitas()); 
                                           
                                           String jMulaiApp = p.getJamMulai() != null ? fmtJam.format(p.getJamMulai()) : "07:00";
                                           String jSelesaiApp = p.getJamSelesai() != null ? fmtJam.format(p.getJamSelesai()) : "21:00";
                                           String tglMApp = p.getTanggalPinjam() != null ? fmtTgl.format(p.getTanggalPinjam()) : "-";
                                           String tglSApp = p.getTanggalKembali() != null ? fmtTgl.format(p.getTanggalKembali()) : "-";
                                           
                                           String jadwalDisplayApp = tglMApp;
                                           if (!tglMApp.equals(tglSApp) && !tglSApp.equals("-")) {
                                               jadwalDisplayApp += " s/d " + tglSApp;
                                           }
                                %>
                                <tr class="hover:bg-gray-50/50 transition">
                                    <td class="p-4 font-mono text-xs font-semibold text-primary"><%= p.getIdPeminjaman() %></td>
                                    <td class="p-4 font-medium text-textmain"><%= p.getIdPengguna() %></td>
                                    <td class="p-4 font-semibold text-textmain"><%= namaFasilitas %></td>
                                    <td class="p-4 text-xs text-gray-600 max-w-[200px] truncate" title="<%= p.getKeperluan() != null ? p.getKeperluan() : "Tidak ada catatan" %>">
                                        <%= p.getKeperluan() != null ? p.getKeperluan() : "-" %>
                                    </td>
                                    <td class="p-4">
                                        <div class="text-xs text-textmain font-medium"><%= jadwalDisplayApp %></div>
                                        <div class="text-[10px] text-gray-500 mt-0.5"><i class="ph-bold ph-clock text-[10px]"></i> <%= jMulaiApp %> - <%= jSelesaiApp %> WIB</div>
                                    </td>
                                    <td class="p-4 align-top">
                                        <div class="flex items-center justify-center gap-2">
                                            <form action="../ApprovalServlet" method="POST" class="m-0 p-0">
                                                <input type="hidden" name="id_peminjaman" value="<%= p.getIdPeminjaman() %>">
                                                <input type="hidden" name="aksi" value="approve">
                                                <button type="submit" class="w-9 h-9 rounded-lg bg-green-50 text-success border border-green-200 hover:bg-success hover:text-white flex items-center justify-center transition shadow-sm" title="Setujui"><i class="ph-bold ph-check text-lg"></i></button>
                                            </form>
                                            <form action="../ApprovalServlet" method="POST" class="m-0 p-0">
                                                <input type="hidden" name="id_peminjaman" value="<%= p.getIdPeminjaman() %>">
                                                <input type="hidden" name="aksi" value="reject">
                                                <button type="submit" class="w-9 h-9 rounded-lg bg-red-50 text-danger border border-red-200 hover:bg-danger hover:text-white flex items-center justify-center transition shadow-sm" title="Tolak"><i class="ph-bold ph-x text-lg"></i></button>
                                            </form>
                                        </div>
                                    </td>
                                </tr>
                                <% } } else { %>
                                <tr><td colspan="6" class="p-8 text-center text-gray-400 text-sm">Hore! Tidak ada antrean pengajuan yang menunggu persetujuan.</td></tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>

                <div class="mt-10 border-t border-gray-100 pt-8">
                    <h1 class="text-2xl font-bold text-primary mb-1">Verifikasi Pembayaran Denda</h1>
                    <p class="text-textmuted text-sm mb-6">Cek dan konfirmasi bukti transfer yang dikirimkan oleh mahasiswa.</p>
                    <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-6">
                        <% if(listVerifikasi != null && !listVerifikasi.isEmpty()) {
                               for(Peminjaman v : listVerifikasi) { %>
                        <div class="bg-gray-50 rounded-2xl border border-gray-200 overflow-hidden flex flex-col hover:shadow-md transition-shadow">
                            <div class="h-48 bg-gray-200 relative group overflow-hidden border-b border-gray-200">
                                <img src="../uploads/<%= v.getBuktiPembayaran() %>" alt="Bukti Transfer" class="w-full h-full object-cover transition duration-500 group-hover:scale-110">
                                <div class="absolute inset-0 bg-primary/40 opacity-0 group-hover:opacity-100 transition-opacity duration-300 flex items-center justify-center backdrop-blur-[2px] cursor-pointer">
                                    <a href="../uploads/<%= v.getBuktiPembayaran() %>" target="_blank" class="bg-white text-primary px-4 py-2 rounded-xl text-xs font-bold shadow-lg flex items-center gap-2 transform translate-y-4 group-hover:translate-y-0 transition-transform duration-300">
                                        <i class="ph-bold ph-magnifying-glass-plus text-base"></i> Lihat Penuh
                                    </a>
                                </div>
                            </div>
                            <div class="p-5 flex flex-col flex-1">
                                <div class="flex items-center gap-3 mb-4">
                                    <div class="w-10 h-10 rounded-full bg-white overflow-hidden shrink-0 border border-gray-200 shadow-sm"><img src="https://i.pravatar.cc/150?img=11" alt="User" class="w-full h-full object-cover"></div>
                                    <div>
                                        <h3 class="font-semibold text-textmain text-sm"><%= v.getIdPengguna() %></h3>
                                        <p class="text-[10px] text-textmuted">Menunggu Konfirmasi</p>
                                    </div>
                                </div>
                                <form action="../ApprovalServlet" method="POST" class="mt-auto">
                                    <input type="hidden" name="id_peminjaman" value="<%= v.getIdPeminjaman() %>">
                                    <input type="hidden" name="aksi" value="lunas">
                                    <button type="submit" class="w-full bg-success text-white text-xs font-semibold py-3 rounded-xl hover:bg-green-600 transition shadow-sm flex items-center justify-center gap-2">
                                        <i class="ph-bold ph-check-circle text-base"></i> Konfirmasi Lunas
                                    </button>
                                </form>
                            </div>
                        </div>
                        <% } } else { %>
                        <div class="col-span-full"><p class="text-sm text-gray-400 text-center py-8">Tidak ada pembayaran yang perlu diverifikasi saat ini.</p></div>
                        <% } %>
                    </div>
                </div>
            </div>

            <div id="content-fasilitas" class="content-section space-y-6 hidden">
                <div class="flex justify-between items-end mb-6">
                    <div>
                        <h1 class="text-2xl font-bold text-primary mb-1">Manajemen Fasilitas</h1>
                        <p class="text-textmuted text-sm">Kelola status dan data seluruh fasilitas, gedung, dan alat.</p>
                    </div>
                    <button onclick="openModalFasilitas('tambah')" class="bg-primary text-white px-5 py-2.5 rounded-xl text-sm font-semibold shadow-md flex items-center gap-2 hover:bg-secondary transition">
                        <i class="ph-bold ph-plus text-base"></i> Tambah Baru
                    </button>
                </div>

                <div class="bg-gray-50 p-4 rounded-2xl border border-gray-200 flex flex-col md:flex-row gap-4 relative z-10">
                    <div class="flex-1 relative">
                        <i class="ph-bold ph-magnifying-glass absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 text-lg"></i>
                        <input type="text" id="searchBox" onkeyup="filterFasilitas()" placeholder="Cari nama fasilitas atau alat..." class="w-full pl-10 pr-4 py-2.5 rounded-xl border border-gray-200 focus:border-primary focus:ring-1 focus:ring-primary outline-none text-sm bg-white">
                    </div>
                    <select id="filterTipeMain" onchange="filterFasilitas()" class="w-full md:w-48 px-4 py-2.5 rounded-xl border border-gray-200 focus:border-primary outline-none text-sm bg-white cursor-pointer">
                        <option value="SEMUA">Semua Kategori</option><option value="RUANGAN">Hanya Ruangan</option><option value="ALAT">Hanya Alat Elektronik</option>
                    </select>
                    <select id="filterLokasiMain" onchange="filterFasilitas()" class="w-full md:w-64 px-4 py-2.5 rounded-xl border border-gray-200 focus:border-primary outline-none text-sm bg-white cursor-pointer">
                        <option value="SEMUA">Semua Lokasi / Gedung</option>
                        <optgroup label="Fasilitas Olahraga & UKM"><option value="Fasilitas Olahraga & Lapangan">Semua Lapangan & Sport Center</option><option value="Gedung Student Center">Gedung Student Center</option></optgroup>
                        <optgroup label="Gedung Rektorat & Umum"><option value="Gedung Bangkit">Gedung Bangkit</option><option value="Gedung Lingian">Gedung Lingian</option><option value="Gedung Panehan">Gedung Panehan</option><option value="GKU">GKU (Grha Wiyata)</option><option value="Gedung Tokong Nanas">Gedung Tokong Nanas</option><option value="TUCH">TUCH / Gedung H</option></optgroup>
                        <optgroup label="Gedung Fakultas"><option value="TULT">TULT</option><option value="FTE">FTE (Barung, Ararkula, Deli)</option><option value="FRI">FRI (Karang, Mangudu)</option><option value="FIF">FIF (Panambulai, Kultubai)</option><option value="FEB">FEB (Manterawu, Miossu, dll)</option><option value="FKB">FKB (Kawalusu, Intata)</option><option value="FIK">FIK (Gedung Sebatik)</option><option value="FIT">FIT (Gedung Selaru)</option></optgroup>
                    </select>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6" id="gridFasilitas">
                    <% for(Fasilitas f : listFasilitas) { 
                        boolean isRuangan = f instanceof Ruangan;
                        String tipeStr = isRuangan ? "RUANGAN" : "ALAT";
                        String lokasiStr = isRuangan ? ((Ruangan)f).getLokasiGedung() : "N/A";
                        String detail1 = isRuangan ? ((Ruangan)f).getKapasitas() + " Orang" : ((AlatElektronik)f).getMerkAlat();
                        String detail2 = isRuangan ? (((Ruangan)f).isBerAc() ? "Ber-AC" : "Non-AC") : ((AlatElektronik)f).getKondisi();
                        String imgUrl = (f.getGambarUrl() != null && !f.getGambarUrl().isEmpty()) ? f.getGambarUrl() : "https://via.placeholder.com/400x250.png?text=CampuSpace";
                    %>
                    <div class="card-fasilitas bg-white rounded-2xl border border-gray-200 overflow-hidden flex flex-col group shadow-sm hover:shadow-md transition-all" data-nama="<%= f.getNamaFasilitas().toLowerCase() %>" data-tipe="<%= tipeStr %>" data-lokasi="<%= lokasiStr.toLowerCase() %>">
                        <div class="h-40 w-full relative overflow-hidden bg-gray-100">
                            <img src="<%= imgUrl %>" alt="Foto" class="w-full h-full object-cover group-hover:scale-105 transition duration duration-500">
                            <div class="absolute top-3 right-3 bg-white/90 backdrop-blur px-2.5 py-1 rounded-md shadow-sm border border-white/20"><span class="text-[10px] font-bold text-primary font-mono"><%= f.getIdFasilitas() %></span></div>
                        </div>
                        <div class="p-5 flex-1 flex flex-col">
                            <h3 class="font-bold text-textmain text-lg leading-tight mb-1"><%= f.getNamaFasilitas() %></h3>
                            <div class="flex items-center gap-1.5 text-xs text-textmuted mb-4"><% if(isRuangan) { %><i class="ph-duotone ph-map-pin text-sm"></i> <%= lokasiStr %><% } else { %><i class="ph-duotone ph-package text-sm"></i> Kategori Alat<% } %></div>
                            <div class="flex items-center gap-2 mb-6 mt-auto">
                                <span class="bg-blue-50 text-primary px-2.5 py-1.5 rounded-md text-[11px] font-semibold"><%= detail1 %></span>
                                <span class="bg-gray-100 text-gray-600 px-2.5 py-1.5 rounded-md text-[11px] font-semibold"><%= detail2 %></span>
                            </div>
                            <div class="grid grid-cols-2 gap-2 border-t border-gray-100 pt-4">
                                <button onclick="bukaModalEdit('<%= f.getIdFasilitas() %>', '<%= f.getNamaFasilitas() %>', '<%= tipeStr %>', '<%= isRuangan ? ((Ruangan)f).getKapasitas() : "" %>', '<%= isRuangan ? ((Ruangan)f).isBerAc() : "" %>', '<%= isRuangan ? ((Ruangan)f).getLokasiGedung().replace("'", "\\'") : "" %>', '<%= !isRuangan ? ((AlatElektronik)f).getJenisAlat() : "" %>', '<%= !isRuangan ? ((AlatElektronik)f).getMerkAlat() : "" %>', '<%= !isRuangan ? ((AlatElektronik)f).getKondisi() : "" %>', '<%= f.getGambarUrl() != null ? f.getGambarUrl() : "" %>')" class="flex items-center justify-center gap-1.5 py-2.5 text-xs font-semibold text-primary bg-blue-50 rounded-xl hover:bg-primary hover:text-white transition"><i class="ph-duotone ph-pencil-simple text-base"></i> Edit</button>
                                <form action="../KelolaFasilitasServlet" method="POST" class="m-0" onsubmit="return confirm('Yakin ingin menghapus fasilitas ini?');">
                                    <input type="hidden" name="aksi" value="hapus">
                                    <input type="hidden" name="id_fasilitas" value="<%= f.getIdFasilitas() %>">
                                    <button type="submit" class="w-full flex items-center justify-center gap-1.5 py-2.5 text-xs font-semibold text-danger bg-red-50 rounded-xl hover:bg-danger hover:text-white transition"><i class="ph-duotone ph-trash text-base"></i> Hapus</button>
                                </form>
                            </div>
                        </div>
                    </div>
                    <% } %>
                </div>
            </div>

            <div id="content-laporan" class="content-section space-y-6 hidden">
                <div class="flex flex-col sm:flex-row justify-between items-start sm:items-end gap-4 mb-6">
                    <div>
                        <h1 class="text-2xl font-bold text-primary mb-1">Laporan & Log Transaksi</h1>
                        <p class="text-textmuted text-sm">Riwayat aktivitas peminjaman dan penyelesaian denda.</p>
                    </div>
                    
                    <div class="flex flex-wrap gap-2 bg-white p-1 rounded-lg border border-gray-200 shadow-sm z-10 relative">
                        <select id="filterStatusLog" onchange="filterLaporan()" class="px-3 py-1.5 text-sm bg-background text-primary rounded-md shadow-sm outline-none font-semibold cursor-pointer">
                            <option value="SEMUA">Semua Status</option>
                            <option value="DIKEMBALIKAN">DIKEMBALIKAN</option>
                            <option value="APPROVED">APPROVED</option>
                            <option value="REJECTED">REJECTED</option>
                            <option value="DENDA">DENDA</option>
                            <option value="SELESAI">SELESAI</option>
                        </select>
                        <select id="filterMonthLog" onchange="filterLaporan()" class="px-3 py-1.5 text-sm bg-background text-primary rounded-md shadow-sm outline-none font-semibold cursor-pointer">
                            <option value="SEMUA">Semua Bulan</option>
                            <% for(int m=0; m<12; m++) { %>
                                <option value="<%= m %>"><%= monthNames[m] %></option>
                            <% } %>
                        </select>
                        <select id="filterYearLog" onchange="filterLaporan()" class="px-3 py-1.5 text-sm bg-background text-primary rounded-md shadow-sm outline-none font-semibold cursor-pointer">
                            <option value="SEMUA">Semua Tahun</option>
                            <% for(int y = currentYear - 2; y <= currentYear + 1; y++) { %>
                                <option value="<%= y %>"><%= y %></option>
                            <% } %>
                        </select>
                    </div>
                </div>

                <div class="bg-white rounded-2xl border border-gray-200 overflow-hidden shadow-sm">
                    <table class="w-full text-left border-collapse">
                        <thead>
                            <tr class="bg-gray-50 border-b border-gray-200 text-xs text-textmuted uppercase tracking-wider">
                                <th class="p-4 font-semibold">ID Reservasi</th>
                                <th class="p-4 font-semibold">Pemohon</th>
                                <th class="p-4 font-semibold">Fasilitas</th>
                                <th class="p-4 font-semibold">Jadwal Pinjam</th>
                                <th class="p-4 font-semibold">Status Akhir</th>
                            </tr>
                        </thead>
                        <tbody class="text-sm divide-y divide-gray-100" id="laporanTableBody">
                            <% 
                            boolean adaLog = false;
                            if(listRiwayat != null && !listRiwayat.isEmpty()) {
                                   for(Peminjaman r : listRiwayat) { 
                                       String stat = r.getStatusPeminjaman();
                                       if(stat == null) continue;

                                       if(!stat.equals("DIKEMBALIKAN") && !stat.equals("APPROVED") && !stat.equals("REJECTED") && !stat.equals("DENDA") && !stat.equals("SELESAI")) {
                                           continue;
                                       }
                                       adaLog = true;
                                       String namaFas = dm.getNamaFasilitas(r.getIdFasilitas()); 
                                       
                                       int logMonth = -1;
                                       int logYear = -1;
                                       if(r.getTanggalPinjam() != null) {
                                           Calendar logCal = new GregorianCalendar();
                                           logCal.setTime(r.getTanggalPinjam());
                                           logMonth = logCal.get(Calendar.MONTH);
                                           logYear = logCal.get(Calendar.YEAR);
                                       }
                                       
                                       // MEMFORMAT KOLOM JADWAL
                                       String jMulaiLog = r.getJamMulai() != null ? fmtJam.format(r.getJamMulai()) : "07:00";
                                       String jSelesaiLog = r.getJamSelesai() != null ? fmtJam.format(r.getJamSelesai()) : "21:00";
                                       String tglMLog = r.getTanggalPinjam() != null ? fmtTgl.format(r.getTanggalPinjam()) : "-";
                                       String tglSLog = r.getTanggalKembali() != null ? fmtTgl.format(r.getTanggalKembali()) : "-";
                                       String tipeInfoLog = (jMulaiLog.equals("07:00") && jSelesaiLog.equals("21:00")) ? "Seharian" : "Per Jam";
                                       
                                       String displayJadwalLog = tglMLog;
                                       if(!tglMLog.equals(tglSLog) && !tglSLog.equals("-")) {
                                           displayJadwalLog += " s/d " + tglSLog;
                                       }

                                       String badgeClass = "bg-gray-100 text-gray-700 border-gray-200";
                                       if(stat.equals("APPROVED")) badgeClass = "bg-green-50 text-success border-green-200";
                                       else if(stat.equals("REJECTED")) badgeClass = "bg-red-50 text-danger border-red-200";
                                       else if(stat.equals("DIKEMBALIKAN")) badgeClass = "bg-blue-50 text-primary border-blue-200";
                                       else if(stat.equals("DENDA")) badgeClass = "bg-orange-50 text-warning border-orange-200";
                                       else if(stat.equals("SELESAI")) badgeClass = "bg-gray-100 text-gray-500 border-gray-200";
                            %>
                            <tr class="log-row hover:bg-gray-50/50 transition" data-month="<%= logMonth %>" data-year="<%= logYear %>" data-status="<%= stat %>">
                                <td class="p-4 font-mono text-xs font-semibold text-textmain"><%= r.getIdPeminjaman() %></td>
                                <td class="p-4 font-medium text-textmain"><%= r.getIdPengguna() %></td>
                                <td class="p-4 text-gray-600"><%= namaFas %></td>
                                <td class="p-4">
                                    <div class="text-xs text-textmain font-medium"><%= displayJadwalLog %></div>
                                    <div class="text-[10px] text-gray-500 mt-0.5"><i class="ph-bold ph-clock text-[10px]"></i> <%= jMulaiLog %> - <%= jSelesaiLog %> WIB (<%= tipeInfoLog %>)</div>
                                </td>
                                <td class="p-4">
                                    <span class="<%= badgeClass %> border px-2.5 py-1 rounded-full text-[10px] font-bold uppercase inline-flex items-center gap-1">
                                        <%= stat %>
                                        <% if(stat.equals("DENDA") && "LUNAS".equals(r.getStatusDenda())) { %>
                                            <i class="ph-bold ph-check-circle text-success text-sm ml-0.5" title="Denda Lunas"></i>
                                        <% } %>
                                    </span>
                                </td>
                            </tr>
                            <% } } 
                            if(!adaLog) { %>
                            <tr id="emptyRow"><td colspan="5" class="p-8 text-center text-gray-400 text-sm">Belum ada riwayat transaksi yang tersimpan.</td></tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

        </div>
    </main>

    <div id="modalFasilitas" class="fixed inset-0 z-[100] hidden bg-gray-900/60 backdrop-blur-sm flex justify-center items-center opacity-0 transition-opacity duration-300">
        <div class="bg-white w-full max-w-2xl rounded-2xl shadow-2xl transform scale-95 transition-transform duration-300 overflow-hidden flex flex-col max-h-[90vh]">
            <div class="px-6 py-4 border-b border-gray-100 flex justify-between items-center bg-gray-50">
                <h3 id="modalTitle" class="text-lg font-bold text-primary flex items-center gap-2"><i class="ph-duotone ph-gear text-xl text-secondary"></i> <span>Form Fasilitas</span></h3>
                <button onclick="closeModalFasilitas()" class="text-gray-400 hover:text-danger p-1 rounded-md transition"><i class="ph-bold ph-x text-lg"></i></button>
            </div>
            <form action="../KelolaFasilitasServlet" method="POST" class="p-8 overflow-y-auto flex-1 space-y-6">
                <input type="hidden" id="inputAksi" name="aksi" value="tambah">
                <div>
                    <label class="block text-sm font-semibold text-textmain mb-2">Kategori Fasilitas</label>
                    <select id="tipeFasilitas" name="tipe_fasilitas" onchange="toggleFormFasilitas()" required class="w-full px-4 py-3 rounded-xl border border-gray-200 focus:border-primary outline-none text-sm bg-white shadow-sm text-gray-700 cursor-pointer">
                        <option value="" disabled selected>-- Pilih Kategori --</option><option value="RUANGAN">Ruangan & Gedung</option><option value="ALAT_ELEKTRONIK">Alat Elektronik & Barang</option>
                    </select>
                </div>
                <div id="formUmum" class="hidden grid grid-cols-1 gap-5">
                    <div class="grid grid-cols-2 gap-5">
                        <div>
                            <label class="block text-sm font-semibold text-textmain mb-2">ID Register</label>
                            <input type="text" id="inputId" name="id_fasilitas" class="w-full px-4 py-3 rounded-xl border border-gray-200 focus:border-primary outline-none shadow-sm text-sm bg-white">
                        </div>
                        <div>
                            <label class="block text-sm font-semibold text-textmain mb-2">Nama Fasilitas</label>
                            <input type="text" id="inputNama" name="nama_fasilitas" class="w-full px-4 py-3 rounded-xl border border-gray-200 focus:border-primary outline-none shadow-sm text-sm bg-white">
                        </div>
                    </div>
                    <div>
                        <label class="block text-sm font-semibold text-textmain mb-2">Link Gambar (URL)</label>
                        <input type="url" id="inputGambar" name="gambar_url" class="w-full px-4 py-3 rounded-xl border border-gray-200 focus:border-primary outline-none shadow-sm text-sm bg-white">
                    </div>
                </div>
                <div id="formRuangan" class="hidden space-y-5 pt-4 border-t border-gray-100 mt-2">
                    <div class="grid grid-cols-2 gap-5">
                        <div><label class="block text-sm font-semibold text-textmain mb-2">Kapasitas</label><input type="number" id="inputKapasitas" name="kapasitas" class="w-full px-4 py-3 rounded-xl border border-gray-200 shadow-sm outline-none text-sm bg-white"></div>
                        <div>
                            <label class="block text-sm font-semibold text-textmain mb-2">Lokasi / Gedung</label>
                            <select id="inputLokasi" name="lokasi" class="w-full px-4 py-3 rounded-xl border border-gray-200 shadow-sm outline-none text-sm bg-white cursor-pointer">
                                <option value="" disabled selected>-- Pilih Lokasi / Gedung --</option>
                                <optgroup label="Fasilitas Olahraga & UKM">
                                    <option value="Fasilitas Olahraga & Lapangan">Fasilitas Olahraga & Lapangan</option>
                                    <option value="Gedung Student Center">Gedung Student Center</option>
                                </optgroup>
                                <optgroup label="Gedung Rektorat & Umum">
                                    <option value="Gedung Bangkit">Gedung Bangkit</option>
                                    <option value="Gedung Lingian">Gedung Lingian</option>
                                    <option value="Gedung Panehan">Gedung Panehan</option>
                                    <option value="GKU">GKU (Grha Wiyata)</option>
                                    <option value="Gedung Tokong Nanas">Gedung Tokong Nanas</option>
                                    <option value="TUCH">TUCH / Gedung H</option>
                                </optgroup>
                                <optgroup label="Gedung Fakultas">
                                    <option value="TULT">TULT</option>
                                    <option value="FTE">FTE (Barung, Ararkula, Deli)</option>
                                    <option value="FRI">FRI (Karang, Mangudu)</option>
                                    <option value="FIF">FIF (Panambulai, Kultubai)</option>
                                    <option value="FEB">FEB (Manterawu, Miossu, dll)</option>
                                    <option value="FKB">FKB (Kawalusu, Intata)</option>
                                    <option value="FIK">FIK (Gedung Sebatik)</option>
                                    <option value="FIT">FIT (Gedung Selaru)</option>
                                </optgroup>
                            </select>
                        </div>
                    </div>
                    <div class="flex items-center gap-3 bg-blue-50/50 p-4 rounded-xl border border-blue-100">
                        <input type="checkbox" name="ber_ac" id="berAc" class="w-4 h-4 text-primary rounded"><label for="berAc" class="text-sm font-semibold text-primary cursor-pointer">Dilengkapi AC</label>
                    </div>
                </div>
                <div id="formAlat" class="hidden space-y-5 pt-4 border-t border-gray-100 mt-2">
                    <div class="grid grid-cols-2 gap-5">
                        <div><label class="block text-sm font-semibold text-textmain mb-2">Jenis Alat</label><input type="text" id="inputJenis" name="jenis_alat" class="w-full px-4 py-3 rounded-xl border border-gray-200 shadow-sm outline-none text-sm bg-white"></div>
                        <div><label class="block text-sm font-semibold text-textmain mb-2">Merk / Brand</label><input type="text" id="inputMerk" name="merk_alat" class="w-full px-4 py-3 rounded-xl border border-gray-200 shadow-sm outline-none text-sm bg-white"></div>
                    </div>
                    <div>
                        <label class="block text-sm font-semibold text-textmain mb-2">Kondisi Barang</label>
                        <select id="inputKondisi" name="kondisi" class="w-full px-4 py-3 rounded-xl border border-gray-200 shadow-sm outline-none text-sm bg-white cursor-pointer">
                            <option value="Sangat Baik">Sangat Baik</option><option value="Baik">Baik</option><option value="Perlu Perhatian">Perlu Perhatian</option>
                        </select>
                    </div>
                </div>
                <div class="pt-6 border-t border-gray-100 flex justify-end gap-3">
                    <button type="button" onclick="closeModalFasilitas()" class="px-6 py-3 rounded-xl border border-gray-200 text-gray-600 font-semibold text-sm hover:bg-gray-50 transition">Batal</button>
                    <button type="submit" class="bg-primary text-white px-8 py-3 rounded-xl font-semibold text-sm hover:bg-secondary transition shadow-md"><i class="ph-bold ph-check text-base"></i> Simpan Data</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function switchMenu(menuId) {
            document.querySelectorAll('.content-section').forEach(el => el.classList.add('hidden'));
            document.getElementById('content-' + menuId).classList.remove('hidden');

            const activeClasses = ['font-semibold', 'text-[#16325B]', 'bg-white', 'shadow-sm'];
            const inactiveClasses = ['text-blue-100', 'hover:bg-white/10'];

            document.querySelectorAll('.nav-item').forEach(el => {
                el.classList.remove(...activeClasses);
                el.classList.add(...inactiveClasses);
            });

            const activeNav = document.getElementById('nav-' + menuId);
            activeNav.classList.remove(...inactiveClasses);
            activeNav.classList.add(...activeClasses);
            
            const titleEl = document.getElementById('page-title');
            if(menuId === 'beranda') titleEl.innerText = "Beranda Sistem";
            if(menuId === 'approval') titleEl.innerText = "Persetujuan Reservasi";
            if(menuId === 'fasilitas') titleEl.innerText = "Kelola Fasilitas";
            if(menuId === 'laporan') titleEl.innerText = "Laporan & Log Transaksi";
        }

        function filterFasilitas() {
            const searchKeyword = document.getElementById('searchBox').value.toLowerCase();
            const filterTipe = document.getElementById('filterTipeMain').value;
            const filterLokasi = document.getElementById('filterLokasiMain').value;
            const cards = document.querySelectorAll('.card-fasilitas');
            const lokasiSelect = document.getElementById('filterLokasiMain');
            
            if (filterTipe === 'ALAT') { lokasiSelect.value = 'SEMUA'; lokasiSelect.disabled = true; lokasiSelect.classList.add('opacity-50'); } 
            else { lokasiSelect.disabled = false; lokasiSelect.classList.remove('opacity-50'); }

            cards.forEach(card => {
                const nama = card.getAttribute('data-nama');
                const tipe = card.getAttribute('data-tipe');
                const lokasi = card.getAttribute('data-lokasi');

                let matchSearch = nama.includes(searchKeyword);
                let matchTipe = (filterTipe === 'SEMUA') || (tipe === filterTipe);
                let matchLokasi = false;
                
                if (filterLokasi === 'SEMUA') { matchLokasi = true; } 
                else if (filterLokasi === 'Fasilitas Olahraga & Lapangan') { matchLokasi = lokasi.includes('sport') || lokasi.includes('futsal') || lokasi.includes('voli') || lokasi.includes('basket') || lokasi.includes('tenis') || lokasi.includes('panahan') || lokasi.includes('lapangan') || lokasi.includes('kolam'); } 
                else { matchLokasi = lokasi.includes(filterLokasi.toLowerCase()); }

                if (matchSearch && matchTipe && matchLokasi) { card.style.display = 'flex'; } else { card.style.display = 'none'; }
            });
        }

        // ==========================================
        // FUNGSI FILTER JS KHUSUS LAPORAN & LOG
        // ==========================================
        function filterLaporan() {
            const filterStatus = document.getElementById('filterStatusLog').value;
            const filterMonth = document.getElementById('filterMonthLog').value;
            const filterYear = document.getElementById('filterYearLog').value;
            
            const rows = document.querySelectorAll('.log-row');
            let visibleCount = 0;
            
            rows.forEach(row => {
                const rowStatus = row.getAttribute('data-status');
                const rowMonth = row.getAttribute('data-month');
                const rowYear = row.getAttribute('data-year');
                
                let matchStatus = (filterStatus === 'SEMUA') || (rowStatus === filterStatus);
                let matchMonth = (filterMonth === 'SEMUA') || (rowMonth === filterMonth);
                let matchYear = (filterYear === 'SEMUA') || (rowYear === filterYear);
                
                if (matchStatus && matchMonth && matchYear) {
                    row.style.display = '';
                    visibleCount++;
                } else {
                    row.style.display = 'none';
                }
            });
            
            let emptyRowFiltered = document.getElementById('emptyRowFiltered');
            let emptyRowOriginal = document.getElementById('emptyRow');
            
            if(emptyRowOriginal) emptyRowOriginal.style.display = 'none';
            
            if(visibleCount === 0 && rows.length > 0) {
                if(!emptyRowFiltered) {
                    emptyRowFiltered = document.createElement('tr');
                    emptyRowFiltered.id = 'emptyRowFiltered';
                    // UPDATE COLSPAN MENJADI 5
                    emptyRowFiltered.innerHTML = '<td colspan="5" class="p-8 text-center text-gray-400 text-sm">Tidak ada riwayat transaksi yang cocok dengan filter.</td>';
                    document.getElementById('laporanTableBody').appendChild(emptyRowFiltered);
                }
                emptyRowFiltered.style.display = '';
            } else if(emptyRowFiltered) {
                emptyRowFiltered.style.display = 'none';
            }
        }

        function openModalFasilitas(mode) {
            const modal = document.getElementById('modalFasilitas');
            document.getElementById('inputAksi').value = mode; 
            if(mode === 'tambah') {
                document.getElementById('modalTitle').innerHTML = '<i class="ph-duotone ph-plus-square text-xl text-secondary"></i> <span>Tambah Fasilitas Baru</span>';
                document.getElementById('inputId').readOnly = false; document.getElementById('inputId').value = '';
                document.getElementById('inputNama').value = ''; document.getElementById('inputGambar').value = '';
            }
            modal.classList.remove('hidden');
            setTimeout(() => { modal.classList.remove('opacity-0'); modal.children[0].classList.remove('scale-95'); }, 10);
        }

        function closeModalFasilitas() {
            const modal = document.getElementById('modalFasilitas');
            modal.classList.add('opacity-0'); modal.children[0].classList.add('scale-95');
            setTimeout(() => { modal.classList.add('hidden'); }, 300);
        }

        function bukaModalEdit(id, nama, tipe, kapasitas, berAc, lokasi, jenis, merk, kondisi, gambar) {
            openModalFasilitas('edit'); 
            document.getElementById('modalTitle').innerHTML = '<i class="ph-duotone ph-pencil-simple text-xl text-secondary"></i> <span>Edit Fasilitas</span>';
            document.getElementById('inputId').value = id; document.getElementById('inputId').readOnly = true; 
            document.getElementById('inputNama').value = nama; document.getElementById('inputGambar').value = gambar;
            
            const selTipe = document.getElementById('tipeFasilitas');
            selTipe.value = tipe === 'RUANGAN' ? 'RUANGAN' : 'ALAT_ELEKTRONIK';
            selTipe.style.pointerEvents = "none"; selTipe.style.backgroundColor = "#f3f4f6";
            toggleFormFasilitas();

            if (tipe === 'RUANGAN') {
                document.getElementById('inputKapasitas').value = kapasitas;
                document.getElementById('berAc').checked = (berAc === 'true');
                document.getElementById('inputLokasi').value = lokasi;
            } else {
                document.getElementById('inputJenis').value = jenis;
                document.getElementById('inputMerk').value = merk;
                document.getElementById('inputKondisi').value = kondisi;
            }
        }

        function toggleFormFasilitas() {
            const tipe = document.getElementById('tipeFasilitas').value;
            if (tipe) {
                document.getElementById('formUmum').classList.remove('hidden');
                document.getElementById('inputId').required = true; document.getElementById('inputNama').required = true;
                if (tipe === 'RUANGAN') {
                    document.getElementById('formRuangan').classList.remove('hidden'); document.getElementById('formAlat').classList.add('hidden');
                } else if (tipe === 'ALAT_ELEKTRONIK') {
                    document.getElementById('formAlat').classList.remove('hidden'); document.getElementById('formRuangan').classList.add('hidden');
                }
            }
        }
    </script>
</body>
</html>