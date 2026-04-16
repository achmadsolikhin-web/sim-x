library(ggplot2)
library(DBI)
koneksi <- DBI::dbConnect(odbc::odbc(),
                          
                          Driver = "MySQL ODBC 8.0 ANSI Driver",
                          Server = "127.0.0.1",
                          Database = "classicmodels",
                          UID = "root",
                          PWD = "080391",
                          Port = 3306)
# Nomer 1, jumlah per produkscale
data1<-dbGetQuery(koneksi,"Select productScale, sum(quantityinstock) as jumlah
from products
group by productScale;")
#Visualisasi
grafik1<-ggplot(data1,aes(x=productScale,y=jumlah))+
  geom_bar(stat = "identity",fill="#0066ff")+
  ggtitle("Jumlah item tiap productScale")
grafik1

#Nomer 2, data pembayaran perbulan tahun 2004
data2<-dbGetQuery(koneksi,"select monthname(paymentDate) as bulan,sum(amount) as jumlah
from payments
where year(paymentDate)=2004
group by month(paymentDate), monthname(paymentDate)
order by month(paymentDate) asc;
")
data2$bulan <- factor(data2$bulan,
                      levels = c("January","February","March","April",
                                 "May","June","July","August",
                                 "September","October","November","December"))
data2
#visualisasi time line
grafik2<-ggplot(data2,aes(x=bulan,y=jumlah))+geom_line(group=1)+geom_point()
grafik2