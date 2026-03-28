# SISOP-1-2026-IT-036

| Modul 1 |     Identitas Praktikan     |
|---------|-----------------------------|
| Nama    | Jonathan Steven Tjahjaputra |
| NRP     | 5027251036                  |
| Kelas   | Sistem Operasi B            |
| Asisten | SCRA                        |

## 1. [soal_1] : ARGO NGAWI JESGEJES

### A. Instruksi
1. Dataset `passenger.csv` harus diunduh ke folder `soal_1`.
2. Script diketik dalam file `KANJ.sh`.
3. Format pemanggilan fungsi pada script adalah :
  ```sh
  awk -f KANJ.sh passenger.csv <opsi>
  ```
4. Opsi `a` : Hitung jumlah penumpang kereta.
5. Opsi `b` : Hitung jumlah gerbong yang dipakai.
6. Opsi `c` : Cari penumpang tertua lalu panggil nama serta usianya.
7. Opsi `d` : Hitung rata-rata usia penumpang (tanpa angka belakang koma).
8. Opsi `e` : Hitung jumlah penumpang business class.
9. Opsi invalid (diluar a / b / c / d / e) akan mengoutput pesan invalid.

### B. Penjelasan
Dimulai dengan setup : Buat folder `soal_1`, unduh `passenger.csv` lalu copy ke WSL lebih tepatnya ke dalam folder `soal_1`,
buat script dengan menjalankan `micro KANJ.sh`.
```sh
BEGIN {
    FS=","
    RS="\r\n"
    mode = ARGV[2]
    ARGV[2] = ""
}
```
1. `FS=","` : Menentukan bahwa pemisah kolom adalah koma (format CSV).
2. `RS="\r\n"` : Mengabaikan enter (\n) dalam pembacaan kolom terakhir (Untuk mencari jumlah gerbong)
3. `NR==1 {next}` : Mengabaikan baris pertama (header).
4. `ARGV[2]` : Menjadikan input setelah `passenger.csv` pada format pemanggilan fungsi sebagai `mode`
Mengambil parameter mode (a / b / c / d / e).


Setelah itu, fungsi dijalankan internal dengan membaca isi `passenger.csv`.
```sh
NR==1 { next }

{
    total++

    carriage[$4]++

    if ($2 > max_age) {
        max_age = $2
        oldest = $1
    }

    sum_age += $2

    if ($3 == "Business") {
        business++
    }
}
```
1. Blok `NR==1 { next }` fungsinya mengabaikan header pada `passenger.csv` yaitu
   `Nama Penumpang | Usia | Kursi Kelas | Gerbong`
2. Blok tanpa nama akan dijalankan saat awk dipanggil, membaca setiap baris pada `passenger.csv`.
3. `total` akan menambah jumlah dirinya sebanyak 1 setiap kali baris dibaca (Jumlah Penumpang).
4. `carriage` akan menyimpan data unik pada kolom 4 (kolom gerbong), secara tidak langsung
   menghitung jumlah gerbong.
5. Blok `if` akan membandingkan kolom 2 pada baris saat ini dengan yang sebelumnya. Jika lebih besar,
   maka kolom 1 (Nama Penumpang) adalah penumpang tertua. Ini akan terus dibandingkan perbaris, yang
   nantinya akan menahan data kolom 1 dan 2 penumpang tertua hingga baris terakhir dibaca.
6. `sum_age` akan menjumlahkan umur (kolom 2) dari setiap baris. Formula rata-rata tidak dijalankan di blok
   ini karena blok sekarang adalah blok perulangan.
7. Blok `if` akan mendeteksi kolom 3 (Kursi Kelas). Jika sel tersebut terdata `Business`, maka jumlah
   variabel `business` bertambah satu.


Dan terakhir untuk bagian per-outputannya,
```sh
END {
    if (mode == "a") {
        print "Jumlah seluruh penumpang KANJ adalah " total " orang"
    }
    else if (mode == "b") {
        print "Jumlah gerbong penumpang KANJ adalah " length(carriage)
    }
    else if (mode == "c") {
        print oldest " adalah penumpang kereta tertua dengan usia " max_age " tahun"
    }
    else if (mode == "d") {
        if (total > 0)
            avg = int(sum_age / total)
        else
            avg = 0
        print "Rata-rata usia penumpang adalah " avg " tahun"
    }
    else if (mode == "e") {
        print "Jumlah penumpang business class ada " business " orang"
    }
    else {
        print "Input Invalid! Gunakan mode: a / b / c / d / e"
    }
}
```
1. Blok `END {}` akan dijalankan setelah semua file berhasil dibaca (dalam konteks ini, `passenger.csv`).
2. awk dengan mode `a`,`c`, dan `e` akan langsung memanggil variabel pada blok tanpa nama.
3. awk `b` memiliki tambahan fungsi `length(_)` yang akan mengukur besar array `carriage`. Hal ini dikarenakan
   data gerbong unik disimpan ke satu "bilik" array, sehingga mengukur lengthnya akan menunjukkan jumlah gerbong.
4. awk `d` menjalankan formula rata-rata terlebih dahulu. Terdapat blok `if` untuk error handling jika pembagi
   adalah nol. Dilakukan dengan menyimpan hasil formula atau nol ke `avg`.
5. awk yang memanggil invalid input akan menampilkan teks invalid seperti pada kode.


### C. Output
Sesuai perintah soal, pemanggilan fungsi script dengan format awk tertera
```sh
awk -f KANJ.sh passenger.csv <opsi>
```
![alt text](assets/soal_1/output_1.png)


## 2. [soal_2] : EKSPEDISI PESUGIHAN GUNUNG KAWI - MAS AMBA

### A. Instruksi
1. Buat direktori `soal_2`, lalu buat folder `ekspedisi` dan masuk ke dalamnya.
1. Pasang tools `gdown` terlebih dahulu (Butuh tambahan pip dan virtual environment).
2. Dengan `gdown`, download google drive dan unduh file `peta-ekspedisi-amba.pdf` pada docs `Soal Shift Modul 1`.
3. Setelah mengunduh, buat folder baru bernama `peta-gunung-kawi` dan masuk ke dalamnya.
4. Buka file pdf secara "concatonate". Didalamnya terdapat link menuju repository yang tidak dapat diunduh dengan `gdown`.
5. Install paket `git`, lalu cloning tautan repository.
6. Dapatkan file baru dengan melihat isi repo hasil cloning. File tersebut adalah `gsxtrack.json` dengan 4 titik yang memiliki informasi `site_name`, `latitude (x)`, dan `longitude (y)`.
7. Buatlah shell script `parserkoordinat.sh` dengan regex (grep, seed, atau awk) untuk mengambil data-data pada poin 6.
8. Susun hasilnya dengan format `id | site_name | latitude | longitude` perbarisnya dan simpan ke file `titik-penting.txt`. `id` adalah urutan pengambilan dan barisnya harus berurutan kebawah (001, 002, dst).
9. 4 titik membentuk persegi, titik tengahnya adalah posisi pusaka. Hitung dengan formula titik tengah persegi ke script `nemupusaka.sh` dan simpan outputnya ke `posisipusaka.txt` dengan format `Posisi Pusaka : (x, y)`.


### B. Penjelasan
Dimulai dengan setup : Buat folder `soal_2` dan buat folder `ekspedisi` didalamnya, tetapi langsung keluar dari folder dan ciptakan direktori baru untuk path virtual environment. Hal ini dilakukan supaya struktur repository tetap mengikuti aturan. Instalasi virtual environment dilakukan dengan menjalankan command berikut per baris.
```sh
sudo apt update
sudo apt install python3-pip python3-venv -y
python3 -m venv env
source env/bin/activate
```
Lalu instal gdown dengan
```sh
pip install gdown
```
Virtual environment akan langsung aktif.


Setelah instalasi selesai, jalankan command berikut di terminal didalam didalam direktori `soal_2`
```sh
gdown <link gdrive pada Soal Shift Modul 1 soal_2>
```
File `peta-ekspedisi-amba.pdf` akan diunduh. Setelah berhasil diunduh, keluar virtual environment dengan `deactivate` lalu lihat isi pdf dengan `cat`. dibagian akhir isi file akan ada link berikut

[https://github.com/pocongcyber77/peta-gunung-kawi.git](https://github.com/pocongcyber77/peta-gunung-kawi.git)

Lalu untuk proses cloningnya dengan menjalankan seri command berikut.
```sh
sudo apt install git -y
git clone https://github.com/pocongcyber77/peta-gunung-kawi.git
```
(Line pertama khusus jika belum menginstall git). Hasil cloning repository akan langsung bisa diakses pada direktori `soal_2`.


Masuk ke dalam repository. Seperti instruksi pada soal, ada file `gsxtrack.json` didalamnya. Buat file baru `parserkoordinat.sh` dan isinya sebagai berikut.
```sh
#!/bin/bash

echo "id,site_name,latitude,longitude" > titik-penting.txt

grep -E '"site_name"|"latitude"|"longitude"' gsxtrack.json | \
sed 's/[",]//g' | \
awk -F': ' '
/site_name/ {name=$2}
/latitude/ {lat=$2}
/longitude/ {
    lon=$2
    id++
    printf "%03d,%s,%s,%s\n", id, name, lat, lon >> "titik-penting.txt"
}
'
```
1. Karena saya memakai micro, `#!/bin/bash` penting untuk menjalankan script layaknya bash.
2. Line `echo` berfungsi untuk mencatat output ke file baru `titik-penting.txt`.
3. Line `grep` hanya akan mengambil data `site_name`, `latitude`, dan `longitude` dari file `gsxtrack.json`.
4. Line `sed` berfungsi untuk menghapus tanda kutip dan koma di seluruh baris (kerapihan format).
5. Line `awk ' '` berfungsi memperbaiki format menjadi bentuk format pada bagian print.
6. Variabel `id` ditambahkan karena permintaan soal dan nilainya naik 1 perbaris, menandakan urutan.
Isi dari file `titik-penting.txt` adalah berikut.
```
id,site_name,latitude,longitude
001,Titik Berak Paman Mas Mba,-7.920000,112.450000
002,Basecamp Mas Fuad,-7.920000,112.468100
003,Gerbang Dimensi Keputih,-7.937960,112.468100
004,Tembok Ratapan Keputih,-7.937960,112.450000
```
Jika dilihat, titik dengan x dan y yang berbeda adalah pada id `001` dan `003`


Lalu untuk menghitung titik tengahnya dilakukan dengan terlebih dahulu membuat file `nemupusaka.sh` berikut.
```sh
#!/bin/bash

read lat1 lon1 <<< $(awk -F',' 'NR==2 {print $3, $4}' titik-penting.txt)
read lat2 lon2 <<< $(awk -F',' 'NR==4 {print $3, $4}' titik-penting.txt)

mid_lat=$(echo "($lat1 + $lat2)/2" | bc -l)
mid_lon=$(echo "($lon1 + $lon2)/2" | bc -l)

echo "Posisi pusaka: $mid_lat, $mid_lon" > posisipusaka.txt
```
1. Dua line `read` untuk mengambil 2 titik dengan x dan y yang berbeda, yaitu baris pertama dan ketiga (NR==1 adalah header sehingga tidak dihitung).
2. `mid_lat` dan `mid_lon` akan menghitung latitude tengah dan longitude tengah.
3. Line `echo` akan mencetak hasil poin 2 ke file baru `posisipusaka.txt`.
Isi dari file `posisipusaka.txt` adalah sebagai berikut.
```
Posisi pusaka: -7.92898000000000000000, 112.45905000000000000000
```


### 3. Output
Karena file `.sh` yang ada hanya mencetak output ke file `.txt`, maka output yang tertera hanya 2 yaitu `titik-penting.txt` dan `posisipusaka.txt`. 


**(Mohon maaf sekali mas/mba asisten, tetapi beberapa elemen "kreatif" pada soal 2 ini mungkin sedikit berlebihan. Secara github ini bakal jadi portofolio nantinya, mungkin kedepannya bisa lebih safe for work)**


![alt text](assets/soal_2/output_2.png)









