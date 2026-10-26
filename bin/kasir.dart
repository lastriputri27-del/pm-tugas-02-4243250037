import 'dart:io';

// Konstanta untuk aturan diskon toko.
const int batasDiskon = 100000;
const int persentaseDiskon = 10;

// Katalog menggunakan Map dengan value berupa record.
final Map<String, ({String nama, String kategori, int harga})> katalog = {
  'P01': (nama: 'Kopi Sidikalang 250 g', kategori: 'Kopi', harga: 45000),
  'P02': (nama: 'Kopi Gayo 250 g', kategori: 'Kopi', harga: 55000),
  'P03': (nama: 'Teh Kayu Aro 100 g', kategori: 'Teh', harga: 25000),
  'P04': (nama: 'Gula Aren 500 g', kategori: 'Pemanis', harga: 30000),
  'P05': (nama: 'Bolu Meranti', kategori: 'Makanan', harga: 80000),
};

// Record untuk menyimpan barang yang berhasil dipesan.
typedef ItemBelanja = ({
  String kode,
  String nama,
  String kategori,
  int jumlah,
  int harga,
  int subtotal,
});

// Mengubah angka menjadi format rupiah, misalnya Rp45.000.
String rupiah(int nilai) {
  final String angka = nilai.toString();
  final StringBuffer hasil = StringBuffer();

  for (int i = 0; i < angka.length; i++) {
    if (i > 0 && (angka.length - i) % 3 == 0) {
      hasil.write('.');
    }
    hasil.write(angka[i]);
  }

  return 'Rp${hasil.toString()}';
}

void main() {
  print('==============================================');
  print('             TOKO OLEH-OLEH MEDAN');
  print('==============================================');

  // Menampilkan katalog dalam bentuk tabel.
  print('KODE'.padRight(8) + 'NAMA PRODUK'.padRight(25) + 'HARGA'.padLeft(12));
  print(List.filled(45, '-').join());

  for (final entry in katalog.entries) {
    print(
      entry.key.padRight(8) +
          entry.value.nama.padRight(25) +
          rupiah(entry.value.harga).padLeft(12),
    );
  }

  // Membaca input pesanan dari terminal.
  print('\nContoh pesanan: P01x2, P03x1');
  stdout.write('Masukkan pesanan: ');

  final String input = stdin.readLineSync() ?? '';

  final List<ItemBelanja> keranjang = [];
  final List<String> ditolak = [];

  // Memisahkan beberapa pesanan berdasarkan koma.
  for (final String bagian in input.split(',')) {
    final String pesanan = bagian.trim();

    if (pesanan.isEmpty) {
      continue;
    }

    // Setiap pesanan harus menggunakan format KODExJUMLAH.
    final List<String> detail = pesanan.split('x');

    if (detail.length != 2) {
      ditolak.add('$pesanan (format salah)');
      continue;
    }

    final String kode = detail[0].trim().toUpperCase();
    final int? jumlah = int.tryParse(detail[1].trim());

    // Pencarian produk dapat menghasilkan null jika kode tidak ditemukan.
    final produk = katalog[kode];

    if (produk == null) {
      ditolak.add('$pesanan (kode tidak ditemukan)');
      continue;
    }

    // Jumlah harus berupa bilangan bulat positif.
    if (jumlah == null || jumlah <= 0) {
      ditolak.add('$pesanan (jumlah tidak valid)');
      continue;
    }

    final int subtotal = produk.harga * jumlah;

    keranjang.add((
      kode: kode,
      nama: produk.nama,
      kategori: produk.kategori,
      jumlah: jumlah,
      harga: produk.harga,
      subtotal: subtotal,
    ));
  }

  // Mengambil subtotal setiap item menggunakan map.
  final List<int> daftarSubtotal = keranjang
      .map((item) => item.subtotal)
      .toList();

  // Menjumlahkan seluruh subtotal menggunakan fold.
  final int total = daftarSubtotal.fold<int>(
    0,
    (akumulasi, subtotal) => akumulasi + subtotal,
  );

  // Diskon 10% berlaku jika total mencapai batas minimum.
  final int diskon = total >= batasDiskon
      ? (total * persentaseDiskon) ~/ 100
      : 0;

  final int totalBayar = total - diskon;
  final int jumlahProdukValid = keranjang.length;

  // Mencetak struk belanja.
  print('\n================ STRUK BELANJA ================');

  if (keranjang.isEmpty) {
    print('Tidak ada barang valid yang dibeli.');
  } else {
    for (final item in keranjang) {
      print(
        '${item.kode} - ${item.nama}\n'
        '  ${item.jumlah} x ${rupiah(item.harga)}'
        ' = ${rupiah(item.subtotal)}',
      );
    }
  }

  print(List.filled(48, '-').join());
  print('Jumlah jenis produk: $jumlahProdukValid');
  print('Total belanja      : ${rupiah(total)}');
  print('Diskon             : ${rupiah(diskon)}');
  print('Total bayar        : ${rupiah(totalBayar)}');

  // Set menyimpan kategori produk tanpa duplikasi.
  final Set<String> kategoriDibeli = keranjang
      .map((item) => item.kategori)
      .toSet();

  print(
    '\nKategori dibeli: '
    '${kategoriDibeli.isEmpty ? '-' : kategoriDibeli.join(', ')}',
  );

  // Menampilkan semua pesanan yang ditolak beserta alasannya.
  if (ditolak.isNotEmpty) {
    print('\nItem yang ditolak:');

    for (final String item in ditolak) {
      print('- $item');
    }
  }

  print('\nTerima kasih telah berbelanja!');
}
