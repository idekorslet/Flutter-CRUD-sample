<?php
    
    require_once 'connection.php';
    require_once 'database_controller.php';
    require_once 'utils.php';
    require_once 'upload_config.php';


    $UPLOAD_FOLDER =  UploadConfig::$UPLOAD_FOLDER;
    $db_ctrl = new DatabaseController();
    $utils = new Utils();


    $is_token_valid = false;
    $product_id = 0;
    $is_edit_image = false;

    // cek apakah file yang diupload lebih besar dari post_max_size yang ada di file php.ini
    if (isset($_SERVER["CONTENT_LENGTH"])) {

        if ($_SERVER["CONTENT_LENGTH"] > ((int)ini_get('post_max_size') * 1024 * 1024)) {
            $utils->sendErrorResponse("File too big");
        }

    }

    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {

        $utils->sendErrorResponse("Please use POST method");

    }

    if (isset($_POST["seller_id"])) {

        $seller_id_string = $_POST["seller_id"];

        if ($utils->isValidInteger($seller_id_string) === false) {
            $utils->sendErrorResponse("Seller id: $seller_id_string - not valid");
        }

        $seller_id = (int)$seller_id_string;

        $sql = "SELECT seller_id FROM sellers WHERE seller_id = $seller_id";
        $seller_count = $db_ctrl->selectData($connection, $sql);

        if (count($seller_count) <= 0) {

            $utils->sendErrorResponse("Seller id: $seller_id - not found");

        }
        
        $product_name = $_POST["name"];
        $desc = $_POST["desc"];
        $price = (int)$_POST["price"];
        $stock = (int)$_POST["stock"];
        
        if (isset($_POST['token'])) {

            $valid_token = $db_ctrl->getValidToken($connection, $seller_id);

            if ($_POST['token'] === $valid_token) {
                $is_token_valid = true;
            }
            else {
                $utils->sendErrorResponse("Invalid token");
            }

        }
        else {
            $utils->sendErrorResponse('Token not found');
        }
    }
    else {
        // echo "seller id not found <br>";
        $utils->sendErrorResponse("Seller id not found");
    }
        
        
    if (isset($_POST["edit_image"])) {

        if ($_POST["edit_image"] === "true") {
            // echo 'is edit image ' . $_POST["edit_image"];
            $is_edit_image = true;
        }
        
    }

    if (isset($_POST["product_id"])) {
        $product_id = (int)$_POST["product_id"];
        // echo "product id to edit is $product_id";
    }
    else {
        // echo "product id to edit not found <br>";
        $utils->sendErrorResponse("Product id not found");
    }


    $seller_folder = $UPLOAD_FOLDER . "/sellers/$seller_id";

    // echo "product id value is: $product_id <br>";
    // var_dump($product_id);F

    if ($is_token_valid) {
        $sql = "UPDATE products SET name=?, description=?, price=?, stock=? WHERE product_id=? AND seller_id=?";
        $data = [$product_name, $desc, $price, $stock, $product_id, $seller_id];
        $db_ctrl->updateData($connection, $data, $sql);

        $total_image_processed = 0;
        $images_url = [];
        $result = [];

        /*================================ INSERT IMAGE INTO DATABASE AND FILE SYSTEM ====================================*/

        if ($is_edit_image) {

            // get image data from database by product id
            $sql = "SELECT image_path, image_index FROM product_images WHERE product_id=$product_id";
            $old_image_data = $db_ctrl->selectData($connection, $sql);
            $old_image_data_count = count($old_image_data);

            if ($old_image_data_count === 0) {
                // echo "No data for product id $product_id in product_images table";
                // return;
                $utils->sendErrorResponse("No data for product id $product_id in product_images table");
            }

            // var_dump($old_image_data[0]);
            // ambil data pertama saja / index ke 0
            // sample data for $img["image_path"] --> /29/products/2/laptop.png --> 29 = seller id, 2 = product number

            $product_no_array = explode("/", $old_image_data[0]["image_path"]);
            // var_dump($product_no_array);
            $product_no_string = $product_no_array[3]; // index no 3 --> laptop.png

            $product_number = (int)$product_no_string;
            // echo "product number:$product_number";


            $valid_images = [];
            $received_images = [];

            if (isset($_FILES["userfile"])) {
                $received_images = $_FILES["userfile"];
                $valid_images = $utils->filesValidator($_FILES["userfile"], UploadConfig::$ALLOWED_IMAGE_EXT, UploadConfig::$MAX_IMAGE_SIZE);
            }
            else {
                $utils->sendErrorResponse("No file received");
            }

            if ( empty($valid_images) ) {
                $utils->sendErrorResponse("No valid image");
            }
            else {

                $new_image_data_count = count($valid_images);
                // echo "old image count: $old_image_data_count / new image count: $new_image_data_count <br>";

                $invalid_file = $utils->invalidFilesData();
                // jika jumlah invalid file > 0, berarti ada image baru yang tidak valid

                if ( !empty($invalid_file) ) {

                    foreach ($invalid_file as $unvalid_file) {
                        $utils->sendErrorResponse($unvalid_file);
                    }

                }


                if ($old_image_data_count > $new_image_data_count) {
                    $remaining = $old_image_data_count - $new_image_data_count;
                    
                    // echo "removing " . $remaining . " remaining image from database for product id: $product_id <br>";
                    
                    $sql = "DELETE FROM product_images WHERE product_id=$product_id AND image_index >= $new_image_data_count";
                    $db_ctrl->deleteData($connection, $sql);
                }

                // echo "<br>Removing all image from file system for product id: $product_id <br>";

                // hapus semua image di file system | delete all image in file system
                for ($i=0; $i < $old_image_data_count; $i++) {
                    $old_image_file = "/sellers" . $old_image_data[$i]["image_path"];

                    $full_path_image = __DIR__ . $UPLOAD_FOLDER . $old_image_file;

                    if (file_exists($full_path_image)) {
                        unlink($full_path_image); // delete old image file in file system
                        // echo "i value: $i | $old_image_file deleted successfully <br>";
                    }
                    else {
                        // echo $full_path_image . " not exists <br>";
                    }
                }

                // echo "<br> saving image into database and file system <br>";

                $products_folder = $seller_folder . "/products/$product_number";
                $images_folder = __DIR__ . $products_folder . "/images";

                // buat folder sesuai seller id jika belum ada foldernya
                if (!is_dir($images_folder)) {
                    // echo "images_folder not exists, creating image folder<br>";
                    mkdir($images_folder, 0755, true);
                }

                // insert new image into database and file system
                $image_index = 0;
                foreach ($valid_images as $img) {
                    // var_dump($img);
                    $image_file = $img["image_file"];
                    $new_image_filename = $img["filename"];
                    $full_path_image = $images_folder . "/" . $new_image_filename;

                    // simpan file ke lokasi tujuan - save file into destination location
                    if (move_uploaded_file($image_file, $full_path_image)) {
                        // echo "$full_path_image created successfully <br>";
                        $total_image_processed++;

                        $img_path_for_database = "/$seller_id/products/$product_number/images/$new_image_filename";

                        // image url list as server response
                        $image_path = $UPLOAD_FOLDER . "/sellers" . $img_path_for_database;
                        $images_url[$image_index] = $image_path;

                        // echo "image path for database is: ";
                        // echo "$img_path_for_database <br>";

                        if ($image_index < $old_image_data_count) {
                            $sql = "UPDATE product_images SET image_path=? , image_index=? WHERE product_id=? AND image_index=?";

                            $data = [$img_path_for_database, $image_index, $product_id, $image_index];

                            $db_ctrl->updateData($connection, $data, $sql);
                            // echo "image index $image_index updated <br>";
                        }
                        else {
                            $sql = "INSERT INTO product_images (product_id, image_path, image_index) VALUES (?, ?, ?)";
                            $data = array(
                                [$product_id, $img_path_for_database, $image_index],
                            );

                            $db_ctrl->insertData($connection, $data, $sql);
                        }
                    }
                    else {
                        echo "failed to create image file: $full_path_image <br>";
                    }

                    $image_index++;
                }

            }
        }

        $result = [
            "info" => $db_ctrl->isUpdateDataOk() ? "OK" : "NOT OK",
            "product_id" => $product_id,
            "is_edit_image" => $is_edit_image,
            "total_image_processed" => $total_image_processed,
            "images_url" => $images_url,
            "error_msg" => $db_ctrl->isUpdateDataOk() ? "" : "No data updated"
        ];
        
        header('Content-Type: application/json');
        echo json_encode($result);
    }
