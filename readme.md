## Flutter CRUD sample
Projek ini adalah penggunaan CRUD menggunakan Flutter dengan server/backend PHP.<br>
This project is how to use CRUD using Flutter with PHP as server/backend.

## App Demo
[![IMAGE ALT TEXT HERE](https://img.youtube.com/vi/Mhmj4SfFIQs/0.jpg)](https://www.youtube.com/watch?v=Mhmj4SfFIQs)

## Struktur Folder / Folder Structure
Ini adalah struktur folder yang saya gunakan untuk menyimpan gambar-gambar.<br>
This is the folder structure i use to store images in the file system.<br>

![folder-struktur](https://github.com/idekorslet/Flutter-CRUD-sample/assets/80518183/8e59554b-e781-4cbc-96f2-b9d6c4abf5e2)
<br><br>
<h3>Path image di database / Image path in database</h3>

![image-path-in-database](https://github.com/idekorslet/Flutter-CRUD-sample/assets/80518183/d08f8b0d-1000-43c0-9108-cc9477f107ac)
<br><br>
<h3>Daftar Dependensi / Dependencies</h3>
1. <a href="https://pub.dev/packages/cached_network_image">cached_network_image</a><br>
2. <a href="https://pub.dev/packages/reorderables">reorderables</a><br>
3. <a href="https://pub.dev/packages/image_picker">image_picker</a><br>
4. <a href="https://pub.dev/packages/fluttertoast">fluttertoast</a><br>
5. <a href="https://pub.dev/packages/infinite_scroll_pagination">infinite_scroll_pagination</a><br>
6. <a href="https://pub.dev/packages/flutter_form_builder">flutter_form_builder</a><br>
7. <a href="https://pub.dev/packages/form_builder_validators">form_builder_validators</a><br>
8. <a href="https://pub.dev/packages/flutter_multi_formatter">flutter_multi_formatter</a><br>
9. <a href="https://pub.dev/packages/carousel_slider">carousel_slider</a><br>
10. <a href="https://pub.dev/packages/smooth_page_indicator">smooth_page_indicator

## Metode yang digunakan / Method Used
Metode yang digunakan untuk proses CRUD ada 2, GET dan POST.<br>
There are 2 methods used for the CRUD process, GET and POST.
<br>
GET --> untuk mengambil data - to get data.
<br>
POST --> untuk membuat, mengubah, menghapus data - to insert, edit & delete data.
<br><br>
| METHOD      | Descriptions     | Urls    |
| :---:       |    :----         |         :---  |
| GET         | default get data | localhost/api/get_data.php?seller_id=1&page=1&limit=20   |
| GET         | get empty stock  | localhost/api/get_data.php?seller_id=1&filter=1&only-empty-stock=1      |
| GET         | to sort data by stock ascending | localhost/api/get_data.php?seller_id=1&filter=1&sortby=stock-asc   |
| GET         | to sort data by price ascending  | localhost/api/get_data.php?seller_id=1&page=2&limit=40&filter=1&sortby=price-asc      |
| GET         | to search data by product name  | localhost/api/get_data.php?seller_id=1&search=1&name=sepatu      |


## Insert new data
![insert-post](https://github.com/idekorslet/Flutter-CRUD-sample/assets/80518183/c0cc1123-9459-4054-b5fa-f37138f9df9c)


## Edit data
![edit-post](https://github.com/idekorslet/Flutter-CRUD-sample/assets/80518183/3f770c3c-894c-4289-b4d2-b6b53982248b)


## Delete data

![delete-post](https://github.com/idekorslet/Flutter-CRUD-sample/assets/80518183/82f8bbbf-9a0c-4948-84ea-52153ea1e940)

## Info tambahan / Additional Info
![dummy-login](https://github.com/idekorslet/Flutter-CRUD-sample/assets/80518183/0f3e53be-0157-480a-82d9-6513e1f07968)


![myproducts](https://github.com/idekorslet/Flutter-CRUD-sample/assets/80518183/18a86fb6-da54-43de-b704-b2ae54ce1d56)


![insert-and-edit](https://github.com/idekorslet/Flutter-CRUD-sample/assets/80518183/68e22359-3478-4588-97e6-b6b0050ed676)

![product-detail](https://github.com/idekorslet/Flutter-CRUD-sample/assets/80518183/5744f38b-d2ac-4823-94fa-5681f431a7b1)

## Support
|  |  |  |
|--|--|--|
| <a href="https://saweria.co/idekorslet"><img alt="saweria" width="180" src="https://user-images.githubusercontent.com/80518183/216806553-4a11d0ef-6257-461b-a3f2-430910574269.svg"></a> | | <a href="https://buymeacoffee.com/idekorslet"><img alt='Buy me a coffee' width="180" src="https://user-images.githubusercontent.com/80518183/216806363-a11d0282-517a-4512-9733-567e0d547078.png"> </a> |
