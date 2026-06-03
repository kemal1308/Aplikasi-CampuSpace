<%-- 
    Document   : katalog
    Created on : 30 May 2026
    Author     : Kemal Farouq
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.ArrayList"%>
<%@page import="models.*"%>
<%@page import="controllers.DataManager"%>
<%
    String idUser = (String) session.getAttribute("idPengguna");
    if(idUser == null) {
        response.sendRedirect("../login.jsp");
        return;
    }

    DataManager dm = new DataManager();
    List<Fasilitas> listFasilitas = dm.getAllFasilitas();
    
    // =====================================================================
    // OPTIMASI PERFORMA: AMBIL SEMUA JADWAL AKTIF 1 KALI (MENCEGAH LEMOT)
    // =====================================================================
    Map<String, List<String>> allJadwalAktif = dm.getAllJadwalAktif();
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cari Fasilitas - CampuSpace</title>
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
            <a href="<%= request.getContextPath() %>/user/katalog.jsp" class="flex items-center gap-3 px-4 py-3 text-sm font-semibold text-primary bg-[#D6E8F5] rounded-xl transition"><i data-lucide="search" class="w-5 h-5"></i><span>Cari Fasilitas</span></a>
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

    <main class="flex-1 flex flex-col h-full overflow-hidden bg-white rounded-tl-3xl shadow-[-10px_0_15px_rgba(0,0,0,0.03)] z-10">
        <header class="h-20 bg-white border-b border-gray-100 flex items-center justify-between px-8 z-10 shrink-0">
            <h3 class="text-xl font-bold text-primary">Katalog Fasilitas</h3>
            <div class="flex items-center gap-6">
                <div class="w-10 h-10 rounded-full border-2 border-gray-200 overflow-hidden shadow-sm">
                    <img src="<%= request.getContextPath() %>/image/Foto.png" alt="User" class="w-full h-full object-cover">
                </div>
            </div>
        </header>

        <div class="flex-1 overflow-y-auto p-8">
            <div class="max-w-7xl mx-auto space-y-6">
                <div>
                    <h1 class="text-2xl font-bold text-primary mb-1">Eksplorasi Fasilitas Kampus</h1>
                    <p class="text-textmuted text-sm">Cari ruangan, gedung, dan alat pendukung untuk kegiatan Anda.</p>
                </div>

                <div class="bg-white p-4 rounded-2xl shadow-sm border border-gray-100 flex flex-col md:flex-row gap-4 relative z-20">
                    <div class="flex-1 relative">
                        <i data-lucide="search" class="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5"></i>
                        <input type="text" id="searchBox" onkeyup="filterFasilitas()" placeholder="Cari nama fasilitas atau alat..." class="w-full pl-10 pr-4 py-2.5 rounded-xl border border-gray-200 focus:border-primary focus:ring-1 focus:ring-primary outline-none text-sm bg-gray-50">
                    </div>
                    <select id="filterTipeMain" onchange="filterFasilitas()" class="w-full md:w-48 px-4 py-2.5 rounded-xl border border-gray-200 focus:border-primary outline-none text-sm bg-gray-50 cursor-pointer">
                        <option value="SEMUA">Semua Kategori</option>
                        <option value="RUANGAN">Hanya Ruangan</option>
                        <option value="ALAT">Hanya Alat Elektronik</option>
                    </select>
                    <select id="filterLokasiMain" onchange="filterFasilitas()" class="w-full md:w-64 px-4 py-2.5 rounded-xl border border-gray-200 focus:border-primary outline-none text-sm bg-gray-50 cursor-pointer">
                        <option value="SEMUA">Semua Lokasi / Gedung</option>
                        <optgroup label="Fasilitas Olahraga & UKM">
                            <option value="Fasilitas Olahraga & Lapangan">Semua Lapangan & Sport Center</option>
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

                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6" id="gridFasilitas">
                    <% for(Fasilitas f : listFasilitas) { 
                        boolean isRuangan = f instanceof Ruangan;
                        String tipeStr = isRuangan ? "RUANGAN" : "ALAT";
                        String lokasiStr = isRuangan ? ((Ruangan)f).getLokasiGedung() : "Kategori Alat";
                        String detail1 = isRuangan ? ((Ruangan)f).getKapasitas() + " Orang" : ((AlatElektronik)f).getMerkAlat();
                        String detail2 = isRuangan ? (((Ruangan)f).isBerAc() ? "Ber-AC" : "Non-AC") : ((AlatElektronik)f).getKondisi();
                        String imgUrl = (f.getGambarUrl() != null && !f.getGambarUrl().isEmpty()) ? f.getGambarUrl() : "https://via.placeholder.com/400x250.png?text=CampuSpace";
                        
                        // AMBIL JADWAL TERBOOKING DARI CACHE (RAM) AGAR SANGAT CEPAT!
                        List<String> jadwalFasilitas = allJadwalAktif.getOrDefault(f.getIdFasilitas(), new ArrayList<String>());
                        boolean hasJadwal = !jadwalFasilitas.isEmpty();
                    %>
                    <div class="card-fasilitas bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden flex flex-col group hover:shadow-lg transition-shadow duration-300" 
                         data-nama="<%= f.getNamaFasilitas().toLowerCase() %>" data-tipe="<%= tipeStr %>" data-lokasi="<%= lokasiStr.toLowerCase() %>">
                        <div class="h-44 w-full relative overflow-hidden bg-gray-100">
                            <img src="<%= imgUrl %>" alt="Foto" class="w-full h-full object-cover group-hover:scale-110 transition duration-700">
                            
                            <div class="absolute top-3 left-3 px-3 py-1 rounded-full text-[10px] font-bold tracking-wide shadow-sm backdrop-blur-sm 
                                <%= !hasJadwal ? "bg-green-100/90 text-green-700 border border-green-200" : "bg-orange-100/90 text-orange-700 border border-orange-200" %>">
                                <%= !hasJadwal ? "TERSEDIA" : "TERJADWAL" %>
                            </div>
                        </div>
                        <div class="p-5 flex-1 flex flex-col">
                            <h3 class="font-bold text-textmain text-lg leading-tight mb-1"><%= f.getNamaFasilitas() %></h3>
                            <div class="flex items-center gap-1.5 text-xs text-textmuted mb-4">
                                <% if(isRuangan) { %><i data-lucide="map-pin" class="w-3.5 h-3.5 text-gray-400"></i> <%= lokasiStr %>
                                <% } else { %><i data-lucide="box" class="w-3.5 h-3.5 text-gray-400"></i> Alat Pendukung<% } %>
                            </div>
                            <div class="flex items-center gap-2 mb-6 mt-auto">
                                <span class="bg-blue-50 text-primary px-2.5 py-1 rounded-md text-[11px] font-semibold"><%= detail1 %></span>
                                <span class="bg-gray-100 text-gray-600 px-2.5 py-1 rounded-md text-[11px] font-semibold"><%= detail2 %></span>
                            </div>
                            
                            <%
                                // Konversi ke HTML
                                StringBuilder htmlJadwal = new StringBuilder();
                                
                                if(!hasJadwal){
                                    htmlJadwal.append("<div class='p-4 bg-green-50 text-green-700 rounded-xl text-sm font-semibold text-center border border-green-200'>Kabar Baik! Fasilitas ini belum memiliki antrean reservasi aktif. Bebas dipinjam!</div>");
                                } else {
                                    htmlJadwal.append("<div class='space-y-2'>");
                                    for(String jdwl : jadwalFasilitas) {
                                        htmlJadwal.append("<div class='flex items-center gap-3 text-sm text-gray-700 bg-gray-50 p-3 rounded-xl border border-gray-200'><span class='w-2 h-2 rounded-full bg-primary shrink-0'></span>").append(jdwl.replace("• ", "")).append("</div>");
                                    }
                                    htmlJadwal.append("</div>");
                                }
                            %>

                            <div class="pt-4 border-t border-gray-100 flex items-center gap-2">
                                <a href="<%= request.getContextPath() %>/user/reservasi.jsp?id=<%= f.getIdFasilitas() %>" class="flex-1 flex items-center justify-center gap-2 py-2.5 text-sm font-semibold text-white bg-[#00346F] rounded-xl hover:bg-secondary transition shadow-md">
                                    Pinjam <i data-lucide="arrow-right" class="w-4 h-4"></i>
                                </a>

                                <button type="button" 
                                        onclick="bukaModalJadwal('<%= f.getNamaFasilitas().replace("'", "\\'") %>', '<%= htmlJadwal.toString().replace("'", "\\'") %>')" 
                                        class="px-3 py-2.5 bg-white border border-gray-300 text-gray-700 text-sm font-semibold rounded-xl hover:bg-gray-50 transition shadow-sm flex items-center justify-center gap-2" title="Lihat Jadwal Booking">
                                    <i data-lucide="calendar-search" class="w-4 h-4 text-primary"></i> Jadwal
                                </button>
                            </div>
                        </div>
                    </div>
                    <% } %>
                </div>
            </div>
        </div>
    </main>

    <div id="modalJadwal" class="fixed inset-0 z-[100] hidden bg-gray-900/60 backdrop-blur-sm flex justify-center items-center opacity-0 transition-opacity duration-300">
        <div class="bg-white w-full max-w-md rounded-3xl shadow-2xl transform scale-95 transition-transform duration-300 overflow-hidden flex flex-col mx-4">
            
            <div class="px-6 py-5 border-b border-gray-100 flex justify-between items-center bg-gray-50/50">
                <h3 class="text-lg font-bold text-primary flex items-center gap-2">
                    <i data-lucide="calendar-days" class="w-5 h-5 text-secondary"></i> Jadwal Terbooking
                </h3>
                <button onclick="tutupModalJadwal()" class="text-gray-400 hover:text-danger p-1 rounded-lg transition-colors hover:bg-red-50">
                    <i data-lucide="x" class="w-5 h-5"></i>
                </button>
            </div>
            
            <div class="p-6 overflow-y-auto max-h-[60vh]">
                <h4 id="namaFasilitasModal" class="font-bold text-textmain mb-4 text-base border-b border-gray-100 pb-2">Nama Fasilitas</h4>
                
                <div id="kontenJadwalModal" class="mb-2"></div>
                
                <div class="mt-6 p-4 bg-blue-50/50 rounded-xl border border-blue-100 flex gap-3">
                    <i data-lucide="info" class="w-5 h-5 text-primary shrink-0 mt-0.5"></i>
                    <p class="text-[11px] text-gray-600 leading-relaxed">
                        <strong class="font-bold text-primary">Catatan Penting:</strong> Anda tidak dapat memesan pada tanggal yang tertera di atas, termasuk <strong class="font-bold text-danger">1 hari sebelumnya</strong> yang digunakan untuk waktu sterilisasi dan pembersihan fasilitas.
                    </p>
                </div>
            </div>
            
            <div class="p-5 border-t border-gray-100 bg-gray-50/50 flex justify-end">
                <button onclick="tutupModalJadwal()" class="px-6 py-2.5 bg-primary text-white text-sm font-bold rounded-xl hover:bg-secondary transition shadow-sm">Tutup Jadwal</button>
            </div>
        </div>
    </div>

    <script>
        lucide.createIcons({ attrs: { 'stroke-width': 1.5 } });

        function filterFasilitas() {
            const searchKeyword = document.getElementById('searchBox').value.toLowerCase();
            const filterTipe = document.getElementById('filterTipeMain').value;
            const filterLokasi = document.getElementById('filterLokasiMain').value;
            const cards = document.querySelectorAll('.card-fasilitas');

            const lokasiSelect = document.getElementById('filterLokasiMain');
            if (filterTipe === 'ALAT') {
                lokasiSelect.value = 'SEMUA';
                lokasiSelect.disabled = true;
                lokasiSelect.classList.add('opacity-50');
            } else {
                lokasiSelect.disabled = false;
                lokasiSelect.classList.remove('opacity-50');
            }

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

        function bukaModalJadwal(namaFasilitas, htmlKonten) {
            const modal = document.getElementById('modalJadwal');
            document.getElementById('namaFasilitasModal').innerText = namaFasilitas;
            document.getElementById('kontenJadwalModal').innerHTML = htmlKonten;
            
            modal.classList.remove('hidden');
            setTimeout(() => { 
                modal.classList.remove('opacity-0'); 
                modal.children[0].classList.remove('scale-95'); 
            }, 10);
        }

        function tutupModalJadwal() {
            const modal = document.getElementById('modalJadwal');
            modal.classList.add('opacity-0'); 
            modal.children[0].classList.add('scale-95');
            setTimeout(() => { modal.classList.add('hidden'); }, 300);
        }
    </script>
</body>
</html>