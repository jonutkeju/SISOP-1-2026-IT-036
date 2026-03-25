#!/bin/bash

tambah_penghuni() {
    echo "=== Tambah Penghuni ==="

	# Perinputan Masuk Sini
    echo -n "Nama: "
    read nama
    echo -n "Nomor Kamar: "
    read kamar
    echo -n "Harga Sewa: "
    read harga
    echo -n "Tanggal Masuk (YYYY-MM-DD): "
    read tanggal
    echo -n "Status (Aktif/Menunggak): "
    read status

    # Validasi Ini Itu
    if ! [[ "$harga" =~ ^[0-9]+$ ]] || [ "$harga" -le 0 ]; then
        echo "Error: Harga harus angka positif"
        echo "Input invalid, ulangi proses penambahan penghuni"
        return
    fi
    if ! date -d "$tanggal" >/dev/null 2>&1; then
        echo "Error: Format tanggal tidak valid"
        echo "Input invalid, ulangi proses penambahan penghuni"
        return
    fi
    today=$(date +%Y-%m-%d)
    if [[ "$tanggal" > "$today" ]]; then
        echo "Error: Tanggal tidak boleh di masa depan"
        echo "Input invalid, ulangi proses penambahan penghuni"
        return
    fi
    if [[ "$status" != "Aktif" && "$status" != "Menunggak" ]]; then
        echo "Error: Status hanya boleh Aktif atau Menunggak"
        echo "Input invalid, ulangi proses penambahan penghuni"
        return
    fi
    if awk -F',' -v k="$kamar" '$2==k {found=1} END{exit !found}' data/penghuni.csv; then
        echo "Error: Nomor kamar sudah terisi"
        echo "Input invalid, ulangi proses penambahan penghuni"
        return
    fi

    # Ini untuk nyimpan
    echo "$nama,$kamar,$harga,$tanggal,$status" >> data/penghuni.csv
    echo "$nama berhasil terdaftar di kamar $kamar, dan berstatus $status"
}

hapus_penghuni() {
    echo "=== Hapus Penghuni ==="

	# Input lekku
    echo -n "Masukkan Nama Penghuni: "
    read -r nama

    # Cari orangnya
    data=$(awk -F',' -v n="$nama" '$1==n {print $0}' data/penghuni.csv)

	# Nyari validasi :(
    if [ -z "$data" ]; then
        echo "Penghuni tidak ditemukan, coba lagi!"
        return
    fi

    # Ambil nomor kamar
    kamar=$(echo "$data" | awk -F',' '{print $2}')

    # Copas tanggal sekarang
    today=$(date +%Y-%m-%d)

    # Simpan ke history
    echo "$data,$today" >> sampah/history_hapus.csv

    # Hapus dari file utama
    awk -F',' -v n="$nama" '$1!=n' data/penghuni.csv > data/temp.csv
    mv data/temp.csv data/penghuni.csv

    echo "$nama tidak lagi menghuni kamar $kamar"
}

lihat_penghuni() {
    echo "=== Daftar Penghuni ==="
    echo ""

	# Isinya cuma Peroutputan
    awk -F',' '
    BEGIN {
        printf "%-5s %-20s %-10s %-15s %-12s\n", "No", "Nama", "Kamar", "Harga", "Status"
        print "---------------------------------------------------------------"
    }
    NR > 1 {
        no++
        printf "%-5d %-20s %-10s %-15s %-12s\n", no, $1, $2, $3, $5

        total++
        if ($5 == "Aktif") aktif++
        else if ($5 == "Menunggak") menunggak++
    }
    END {
        print "---------------------------------------------------------------"
        printf "Total Penghuni     : %d\n", total
        printf "Status Aktif       : %d\n", aktif
        printf "Status Menunggak   : %d\n", menunggak
    }
    ' data/penghuni.csv
}

update_status() {
    echo "=== Update Status Penghuni ==="

    echo -n "Nama Penghuni: "
    read -r nama

    echo -n "Status Baru (Aktif/Menunggak): "
    read -r status_baru

    # Valid ga banh
    if [[ "$status_baru" != "Aktif" && "$status_baru" != "Menunggak" ]]; then
        echo "Error: Status hanya boleh Aktif atau Menunggak"
        echo "Input invalid, ulangi proses update status"
        return
    fi

    # Valid ga banh pt 2
    if ! awk -F',' -v n="$nama" '$1==n {found=1} END{exit !found}' data/penghuni.csv; then
        echo "Penghuni tidak ditemukan, coba lagi!"
        return
    fi

    # Update status pake awk
    awk -F',' -v n="$nama" -v s="$status_baru" '
    BEGIN {OFS=","}
    NR==1 {print; next}
    {
        if ($1 == n) {
            $5 = s
        }
        print
    }
    ' data/penghuni.csv > data/temp.csv

    mv data/temp.csv data/penghuni.csv

    echo "$nama berhasil diupdate menjadi status $status_baru"
}

laporan_keuangan() {
    echo "=== Laporan Keuangan ==="

    bulan=$(date +%m)
    tahun=$(date +%Y)

	# Peroutputan lagi
    awk -F',' -v bln="$bulan" -v thn="$tahun" '
    BEGIN {
        pemasukan=0
        tunggakan=0
        kamar=0
        idx=0
    }
    NR > 1 {
        kamar++

        if ($5 == "Aktif") {
            pemasukan += $3
        } 
        else if ($5 == "Menunggak") {
            tunggakan += $3
            idx++
            nama[idx] = $1
            hutang[idx] = $3
        }
    }
    END {
        print "============================"
        print "Laporan Bulan " bln " Tahun " thn
        print "Total Pemasukan : " pemasukan
        print "Total Tunggakan : " tunggakan
        print "Kamar Terisi    : " kamar
        print "------------------------------------------------"
        print "Daftar Penghuni Menunggak"

        for (i = 1; i <= idx; i++) {
            printf "%d. %s : %s\n", i, nama[i], hutang[i]
        }

        print "============================"
    }
    ' data/penghuni.csv > rekap/laporan_bulanan.txt

    echo ""
    cat rekap/laporan_bulanan.txt
    echo ""
    echo "Laporan berhasil disimpan ke rekap/laporan_bulanan.txt"
}

# Setup cron dan argumennya
if [[ "$1" == "--check-tagihan" ]]; then
    mkdir -p log
    now=$(date "+%Y-%m-%d %H:%M:%S")

    awk -F',' -v waktu="$now" '
    NR > 1 && $5 == "Menunggak" {
        printf "[%s] TAGIHAN: %s (Kamar %s) – Menunggak Rp%s\n",
        waktu, $1, $2, $3
    }
    ' data/penghuni.csv >> log/tagihan.log

    exit 0
fi
# Yang ini fungsi cronnya
kelola_cron() {
    while true; do
        clear
        echo "=== KELOLA CRON ==="
        echo "1. Lihat Cron Job Aktif"
        echo "2. Tambahkan Cron Job Pengingat"
        echo "3. Hapus Cron Job Pengingat"
        echo "4. Kembali"
        echo "======================="

        echo -n "Pilih opsi: "
        read pilihan

        case $pilihan in
            1)
                echo "Cron aktif:"
                crontab -l 2>/dev/null | grep kost_slebew || echo "Tidak ada cron aktif"
                read -p "ENTER..."
                ;;

            2)
                echo -n "Masukkan jam (00-23): "
                read jam

                echo -n "Masukkan menit (00-59): "
                read menit

                # Validasi 2 digit
                if ! [[ "$jam" =~ ^[0-9]{2}$ ]] || ! [[ "$menit" =~ ^[0-9]{2}$ ]]; then
                    echo "Format jam/menit harus 2 digit!"
                    read -p "ENTER..."
                    continue
                fi

                script_path=$(realpath kost_slebew.sh)

                # overwrite cron karna cuma boleh satu
                echo "$menit $jam * * * $script_path --check-tagihan" | crontab -

                echo "Cron berhasil diset pada $jam:$menit"
                read -p "ENTER..."
                ;;

            3)
                crontab -l 2>/dev/null | grep -v kost_slebew | crontab -
                echo "Cron berhasil dihapus"
                read -p "ENTER..."
                ;;

            4)
                break
                ;;

            *)
                echo "Pilihan tidak valid"
                read -p "ENTER..."
                ;;
        esac
    done
}

# Ini bagian menu
while true; do
    clear 
    echo "██╗  ██╗ ██████╗ ███████╗████████╗ "
    echo "██║  ██║██╔═══██╗██╔════╝╚══██╔══╝ "
    echo "██████═╝██║   ██║███████╗   ██║    "
    echo "██╔══██╗██║   ██║╚════██║   ██║    "
    echo "██║  ██║╚██████╔╝███████║   ██║    "
    echo "╚═╝  ╚═╝ ╚═════╝ ╚══════╝   ╚═╝    "
    echo "=================================="
    echo "1. Tambah Penghuni"
    echo "2. Hapus Penghuni"
    echo "3. Lihat Penghuni"
    echo "4. Update Status Penghuni"
    echo "5. Cetak Laporan Keuangan"
    echo "6. Kelola Cron"
    echo "7. Keluar Program"
    echo "=================================="

    echo -n "Pilih opsi: "
    read pilihan

    case $pilihan in
        1)
            tambah_penghuni
            echo ""
            echo "Tekan ENTER untuk kembali ke menu..."
            read
            ;;
        2)
            hapus_penghuni
            echo ""
            echo "Tekan ENTER untuk kembali ke menu..."
            read
            ;;
        3)
            lihat_penghuni
            echo ""
            echo "Tekan ENTER untuk kembali ke menu..."
            read
            ;;
        4)
            update_status
            echo ""
            echo "Tekan ENTER untuk kembali ke menu..."
            read
            ;;
        5)
            laporan_keuangan
            echo ""
            echo "Tekan ENTER untuk kembali ke menu..."
            read
            ;;
        6)
            kelola_cron
            ;;
        7)
            echo "Mas Amba Keluar Program"
            break
            ;;
        *)
            echo "Pilihan tidak valid"
            read -p "Tekan ENTER..."
            ;;
    esac
done
