<?php

    require_once 'connection.php';
    require_once 'database_controller.php';
    require_once 'utils.php';
    require_once 'upload_config.php';


    $utils = new Utils();


    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {

        $utils->sendErrorResponse("Please use POST method");

    }

    $db_ctrl = new DatabaseController();
    $is_token_valid = false;
    $seller_id = 0;

    if (isset($_POST['seller_id'])) {
        $seller_id = (int)$_POST['seller_id'];

        $sql = "SELECT seller_id FROM sellers WHERE seller_id = $seller_id";
        $seller_count = $db_ctrl->selectData($connection, $sql);

        if (count($seller_count) <= 0) {

            $utils->sendErrorResponse("Seller id: $seller_id - not found");

        }
    }
    else {
        $utils->sendErrorResponse("Seller id not found");
    }


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
        $utils->sendErrorResponse("Token not found");
    }


    $result = [];
    $is_product_deleted = false;
    $UPLOAD_FOLDER = __DIR__ . UploadConfig::$UPLOAD_FOLDER;

    if ($is_token_valid) {

        if (isset($_POST['product_id'])) {
            $product_id = $_POST['product_id'];
        }
        else {
            $utils->sendErrorResponse("Product id not found");
        }


        // get image data (image path) from product images in database
        $sql = "SELECT image_path FROM product_images WHERE product_id=$product_id";
        $old_image_path = $db_ctrl->selectData($connection, $sql);

        /*
            $old_image_path output:

            array(2) {
                [0]=> array(1) { ["image_path"]=> string(32) "/29/products/16/images/image1.jpg" }
                [1]=> array(1) { ["image_path"]=> string(44) "/29/products/16/images/image2.png" }
            }
        
        */

        //  ==========================  delete product image folder from file system ==========================

        // get folder name from product number (after "products" folder), take it from first array

        // var_dump($old_image_path[0]["image_path"]); // output: "/29/products/16/images/image1.jpg"

        if (!empty($old_image_path)) {

            $folder_product_no = explode('/', $old_image_path[0]["image_path"]); // product number folder is in index 3
            // var_dump($folder);

            $product_dir = "$UPLOAD_FOLDER/sellers/$seller_id/products/$folder_product_no[3]";

            $utils->removeDirectory($product_dir);

        }
        

        //  ========================== delete image from product image in database ==========================
        $sql = "DELETE FROM product_images WHERE product_id=$product_id";
        $db_ctrl->deleteData($connection, $sql);

        // ========================== delete product from database =================================
        $sql = "DELETE FROM products WHERE product_id=$product_id AND seller_id=$seller_id";
        $db_ctrl->deleteData($connection, $sql);
        $is_product_deleted = $db_ctrl->total_data_deleted > 0;

    }

    $result = [
        "info" => $is_product_deleted ? "OK" : "NOT OK",
        "error_msg" => $is_product_deleted ? "" : "No product deleted - Product id or Seller id not found"
    ];

    header('Content-Type: application/json');
    echo json_encode($result);
