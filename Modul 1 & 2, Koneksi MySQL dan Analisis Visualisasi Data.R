## Modul 1, Koneksi SQL ke R
#Koneksi ke My sql
library(DBI)
koneksi <- DBI::dbConnect(odbc::odbc(),
                       
                       Driver = "MySQL ODBC 8.0 ANSI Driver",
                       Server = "127.0.0.1",
                       Database = "classicmodels",
                       UID = "root",
                       PWD = "080391",
                       Port = 3306)

## Modul 2, analisis data dan visualisasi data dari database SQL di R


## Fungsi default BDI untuk manajemen data
#melihat nama tabel yang ada dalam suatu database
dbListTables(koneksi)
# melihat nama kolom yang ada dalam suatu tabel yang adda dalam suatu data base
dbListFields(koneksi,"customers")
# melihat isi tabel yang ada dalam suatu database
dbReadTable(koneksi,"customers")

## manajemen data dengan menggunakan query sql
# misal untuk melihat nama tabel dalams suatu database
dbGetQuery(koneksi,"SHOW TABLES")
# melihat deskripsi dari suatu tabel misal tabel products
dbGetQuery(koneksi,"DESCRIBE PRODUCTS")
dbGetQuery(koneksi,"SELECT*FROM products")
# karyawan dari boston
dbGetQuery(koneksi,"select concat(firstName,' ',lastName) As Nama, city
           from employees
           join offices using(officeCode)
           where city='Boston'")
# menyimpan hasil query dalam suatu dataframe
data_produk<-dbGetQuery(koneksi,"select*from PRODUCTS")
## Visualisasi menggunana data dari query sql
#1. AMbil data yang sesuai
dt1 <- dbGetQuery(koneksi, "SELECT productline,COUNT(*) AS jumlah FROM products GROUP BY productline")
# ubah tampilan data
dt1$jumlah<-as.numeric(dt1$jumlah) #mengubah data menjadi numeric
nilai1<-round(dt1$jumlah/sum(dt1$jumlah)*100,2) #membuat nilai dalam persentase

#membuat grafik menggunakan ggplot2
library(ggplot2)
# Buat dasar grafik
pie <- ggplot(dt1, aes(x="", y=jumlah, fill=productline)) +geom_bar(stat="identity", width=1)
# ngubah ke pie chart
pie <- pie + coord_polar("y", start=0) + geom_text(aes(label = paste0(nilai1, "%")), position = position_stack(vjust = 0.5))
# menambah warna dengan kode hex
pie <- pie + scale_fill_manual(values=c("#55DDE0", "#33658A", "#FF00FF", "#2F4858", "#F6AE2D", "#F26419", "#999999")
# menghaous label dan menambahkan judul
pie <- pie + labs(x = NULL, y = NULL, fill = NULL, title = "Product Line - Market Share")
# merapikan chart
pie <- pie + theme_classic() + theme(axis.line = element_blank(),axis.text = element_blank(),axis.ticks = element_blank(),plot.title = element_text(hjust = 0.5, color = "#666666"))

# Query untuk mencari total penjualan per lini produk
data2<-dbGetQuery(koneksi,"select pl.productline, sum(o.quantityordered*o.priceeach) as totalSales
from productlines pl
join products p on p.productline=pl.productline
join orderdetails o on p.productcode=o.productcode
group by pl.productline
order by totalSales desc;")
data2
#membuat grafik bar untuk emncatat pejualan per lini produk
grafik2<-ggplot(data2, aes(x = reorder(productline, -totalSales), y = totalSales)) + geom_bar(stat = "identity", fill = "orange", alpha = 1) + theme_minimal() +labs(title = "Total Penjualan per Lini Produk",x = "Lini Produk", y = "Total Penjualan (USD)") + theme(axis.text.x = element_text(angle = 45, hjust = 1))
grafik2

## Membuat grafik untuk tren penjualan tiap bulan
query3 <- "SELECT DATE_FORMAT(orderDate, '%Y-%m') AS orderMonth,
SUM(quantityOrdered * priceEach) AS monthlySales
FROM orders
JOIN orderdetails ON orders.orderNumber = orderdetails.orderNumber
GROUP BY orderMonth"
data3<-dbGetQuery(koneksi,query3)
data3
# Visualisasi data untuk tren penjualan
grafik3<-ggplot(data3, aes(x = as.Date(paste(orderMonth, '-01', sep = ''), format = '%Y-%m-%d'), y = monthlySales)) + geom_line(color = "blue") +theme_minimal() + labs(title = "Tren Penjualan Bulanan", x = "Bulan", y = "Total Penjualan (USD)")
grafik3




                                                                                                                                                               