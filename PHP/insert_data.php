<?php
    require_once 'connection.php';
    require_once 'database_controller.php';
    require_once 'utils.php';
    require_once 'upload_config.php';


    $UPLOAD_FOLDER = UploadConfig::$UPLOAD_FOLDER;
    $db_ctrl = new DatabaseController();
    $utils = new Utils();


    $is_token_valid = false;
    $valid_images = [];

    // cek apakah file yang diupload lebih besar dari post_max_size yang ada di file php.ini
    if (isset($_SERVER["CONTENT_LENGTH"])) {

        if ($_SERVER["CONTENT_LENGTH"] > ((int)ini_get('post_max_size') * 1024 * 1024)) {
            $utils->sendErrorResponse("File too big");
        }

    }
    

    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {

        $utils->sendErrorResponse("Please use POST method");

    }


    if (isset($_FILES["userfile"])) {
        $valid_images = $utils->filesValidator($_FILES["userfile"], UploadConfig::$ALLOWED_IMAGE_EXT, UploadConfig::$MAX_IMAGE_SIZE);
    }
    else {
        $utils->sendErrorResponse("No file received");
    }
    
    if ( empty($valid_images) ) {
        $utils->sendErrorResponse("No valid image");
    }

    if (isset($_POST["seller_id"])) {
        $seller_id_string = $_POST["seller_id"];

        if ($utils->isValidInteger($seller_id_string) === false) {
            $utils->sendErrorResponse("Seller id: $seller_id_string - not valid");
        }

        $seller_id = (int)$seller_id_string;

        $sql = "SELECT seller_id FROM sellers WHERE seller_id = $seller_id";
        $seller_count = count($db_ctrl->selectData($connection, $sql));

        if ($seller_count <= 0) {

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
        $utils->sendErrorResponse("Seller id not found");
    }


    /*================================ INSERT IMAGE INTO DATABASE AND FILE SYSTEM ====================================*/
    
    $total_image_processed = 0;
    $images_url = [];
    $result = [];
    $product_id = 0;
    // $last_inserted_id = 0;

    // insert data hanya jika image & token valid | insert data only if image & token valid
    if (!empty($valid_images) && $is_token_valid) {

        $seller_folder = __DIR__ . $UPLOAD_FOLDER . "/sellers/$seller_id";
        $seller_history_json = "$seller_folder/histories.json";

        // buat seller folder jika belum ada foldernya
        if (!is_dir($seller_folder)) {
            mkdir($seller_folder, 0755, true);
        }

        // jika file histories.json seller belum ada maka buat dulu file json-nya
        if (!file_exists($seller_history_json)) {
            $history = [
                "total_product" => 0
            ];
            
            $utils->createJsonFile($seller_history_json, $history, false);

            $user_product_count = 0;
        }
        else {
            // $user_product_count = $utils->getLastSellerProductCount("$UPLOAD_FOLDER/sellers/$seller_id/histories.json");
            $user_product_count = $utils->getLastSellerProductCount($seller_history_json);
        }

        // echo "user last product count: $user_product_count <br>";

        $sql = "INSERT INTO products (seller_id, name, description, price, stock) VALUES (?, ?, ?, ?, ?)";
        $data = array(
            [$seller_id, $product_name, $desc, $price, $stock],
        );

        $db_ctrl->insertData($connection, $data, $sql);

        $product_number = $user_product_count + 1;

        // update data "total_product" yang ada di file histories.json
        $utils->updateSellerProductCountJson($seller_history_json, $product_number);

        $product_id = (int)$db_ctrl->last_inserted_id;

        // echo "product id from db: $product_id <br>";

        $products_folder = $seller_folder . "/products/$product_number";
        $images_folder = $products_folder . "/images";

        if (!is_dir($images_folder)) {
            // echo "images_folder not exists, creating image folder<br>";
            mkdir($images_folder, 0755, true);
        }

        $image_index = 0;

        // var_dump($valid_images);
        // var_dump result for $valid_images:
        /**
         * array(2){
         *        [0]=>array(2){
         *            ["filename"]   => string(9)"image1.jpg"
         *            ["image_file"] = >string(24)"E:\xampp\tmp\phpE0CC.tmp"
         *        }
         *        [1]=>array(2){
         *            ["filename"]   => string(21)"image2.png"
         *            ["image_file"] => string(24)"E:\xampp\tmp\phpE0CD.tmp"
         *        }
         *    }
         * 
         *  */    

        foreach ($valid_images as $img) {
            // var_dump($img);
            // $image_path = $img["fullpath_image_name"];
            $image_file = $img["image_file"];
            $new_image_filename = $img["filename"];
            $full_path_image = $images_folder . "/" . $new_image_filename; // combine folder path with filename of image

            // simpan file ke lokasi tujuan
            if (move_uploaded_file($image_file, $full_path_image)) {
                // echo "$image_path created successfully <br>";
                $total_image_processed++;

                $img_path_for_database = "/$seller_id/products/$product_number/images/$new_image_filename";

                $image_path = $UPLOAD_FOLDER . "/sellers" . $img_path_for_database;
                $images_url[$image_index] = $image_path;

                // echo "image path for database is: ";
                // echo "$img_path_for_database <br>";

                // jika ingin simpan file ke database
                // $sql = "INSERT INTO product_images (product_id, image_path, image_file) VALUES (?, ?, ?)";
                // $data = array(
                //     [25, $image_path, file_get_contents($full_path_image)],
                // );

                // jika simpan data ke database tanpa file
                $sql = "INSERT INTO product_images (product_id, image_path, image_index) VALUES (?, ?, ?)";
                $data = array(
                    [$product_id, $img_path_for_database, $image_index],
                );

                $db_ctrl->insertData($connection, $data, $sql);

            }
            else {
                // echo "failed to create image file: $full_path_image <br>";
            }

            $image_index++;
        }

    }

    $result = [
        "info" => "OK",
        "product_id" => $product_id,
        "total_image_processed" => $total_image_processed,
        "images_url" => $images_url
    ];

    header('Content-Type: application/json');
    echo json_encode($result);
