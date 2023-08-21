<?php

    require 'connection.php';
    require 'database_controller.php';
    require 'utils.php';
    require_once 'upload_config.php';


    if ($_SERVER['REQUEST_METHOD'] === 'GET') {

        $utils = new Utils();


        // ********************* seller id check ************************** //

        if (isset($_GET['seller_id'])) {
            $seller_id = $_GET['seller_id'];

            if ($utils->isValidInteger($seller_id) === false) {
                $utils->sendErrorResponse("Wrong format seller id value");
            }
        }
        else {
            $utils->sendErrorResponse("Seller id not found");
        }

        // ********************* page number check ************************** //

        $page = 1;
        $limit = 10; // limit minimal = 10, maximal = 40

        if (isset($_GET['page'])) {

            if ($utils->isValidInteger($_GET['page']) === false) {
                $utils->sendErrorResponse("Wrong format page value");
            }

            $page = (int)$_GET['page'];
        }

        // ********************* limit check ************************** //

        if (isset($_GET['limit'])) {

            if ($utils->isValidInteger($_GET['limit']) === false) {
                $utils->sendErrorResponse("Wrong format limit value");
            }

            $limit = (int)$_GET['limit'];

            $limit = $limit < 10 ? 10 : $limit;
            $limit = $limit > 40 ? 40 : $limit;
        }

        // *********************** search check *************************** //
        // jika pencarian aktif, maka abaikan cek filter
        // if search active, then ignore the filter check

        $is_search_active = false;
        $product_name_search = '';

        if (isset($_GET['search'])) {

            $is_search_active = filter_var($_GET['search'], FILTER_VALIDATE_BOOLEAN); // get boolean value from url string

            if ($is_search_active) {

                if (isset($_GET['name']) === false || $_GET['name'] === "") {

                    $utils->sendErrorResponse("Please set the product name you want to search");

                }

                $product_name_search = " AND name LIKE '%" . $_GET['name'] . "%'";

            }

        }


        // ********************* filter check ************************** //

        $filter_query = '';
        $order_query = '';
    
        if (!$is_search_active) {

            if (isset($_GET['filter'])) {

                $is_filter_active = filter_var($_GET['filter'], FILTER_VALIDATE_BOOLEAN); // get boolean value from url string
    
                if ($is_filter_active) {
    
                    $sort_stock_ascending = true;
                    $sort_price_ascending = true;
    
                    // check the value key of "only-empty-stock".
                    // if true then user request for only empty stock
    
                    if (isset($_GET['only-empty-stock'])) {
    
                        $is_empty_stock_only = filter_var($_GET['only-empty-stock'], FILTER_VALIDATE_BOOLEAN);
    
                        if ($is_empty_stock_only) {
                            $filter_query = $filter_query . " AND stock=0";
                        }
    
                    }
    
    
                    if (isset($_GET['sortby'])) {
    
                        $sort_data = $_GET['sortby']; // value --> stock-asc_price-desc
    
                        $stock_string_valid = ["stock-asc", "stock-desc"];
                        $price_string_valid = ["price-asc", "price-desc"];
    
                        // get stock order/sort method --> asc, desc, or nothing
                        foreach ($stock_string_valid as $valid_string) {
    
                            if (str_contains($sort_data, $valid_string)) {
                                $asc_or_desc = str_contains($valid_string, "asc") ? "ASC" : "DESC";
                                $order_query = $order_query . " ORDER BY stock $asc_or_desc";
                                break;
                            }
    
                        }
    
                        // get price order/sort method
                        foreach ($price_string_valid as $valid_string) {
    
                            if (str_contains($sort_data, $valid_string)) {
                                $asc_or_desc = str_contains($valid_string, "asc") ? "ASC" : "DESC"; // if $valid_string === "asc" then "ASC" else "DESC"
    
                                if ($order_query === "") {
                                    $order_query = $order_query . " ORDER BY price $asc_or_desc";
                                }
                                else {
                                    $order_query = $order_query . ", price $asc_or_desc";
                                }
                                
                                break;
                            }
    
                        }
                    }
    
                }
        
            }

        }
        

        // ***************************** get data from database *********************************** //


        $index_from = $page * $limit - $limit;

        $db_ctrl = new DatabaseController();

        $total_data_sql = "SELECT COUNT(*) as total FROM products WHERE seller_id=$seller_id";

        $total_data_sql = $total_data_sql . ($is_search_active ? $product_name_search : $filter_query); // combine $total_data_sql with $product_name_search or $filter_query

        $total_data = $db_ctrl->selectData($connection, $total_data_sql)[0]["total"];

        
        $products_data = [];

        if ($total_data > 0) {

            $sql = "
                SELECT 
                    a.product_id, a.seller_id, a.name, a.description, a.price, a.stock,
                    b.image_path, b.image_index
                FROM 
                    products a, product_images b
                WHERE 
                    a.seller_id = $seller_id 
                    AND
                    a.product_id = b.product_id
                    $product_name_search
                    $filter_query
                GROUP BY a.product_id
                $order_query
                LIMIT $index_from, $limit
            ";


            $data_from_db = $db_ctrl->selectData($connection, $sql);
            // echo $sql;
            // echo json_encode($data_from_db);
            // exit;

            $images_path = [];
            
            $UPLOAD_FOLDER = UploadConfig::$UPLOAD_FOLDER;

            $counter = 0;
            foreach ($data_from_db as $product) {

                $product_id = $product["product_id"];

                // get product image from database by product id
                $sql = "
                    SELECT product_id, image_path FROM product_images WHERE product_id = $product_id
                ";

                $counter++;
                $close = $counter >= count($data_from_db);

                $images_from_db = $db_ctrl->selectData($connection, $sql, $close);
                
                foreach ($images_from_db as $img) {

                    $product_id_image = $img["product_id"];

                    if ($product_id_image === $product_id) {
                        $images_path[$product_id][] = $UPLOAD_FOLDER . "/sellers" . $img["image_path"];  // add new value into array ($images_path) by product_id. [] --> add new item = $image_path[$product_id].add($img_path)
                    }

                }

                $products_data[] = [
                    "id" => $product_id,
                    "seller_id" => $seller_id,
                    "name" => $product["name"],
                    "description" => $product["description"],
                    "price" => $product["price"],
                    "stock" => $product["stock"],
                    "images_url" => $images_path[$product_id]
                ];
            }

        }
        

        $total_data_shown =  count($products_data);
        $index_to = $index_from + $total_data_shown - 1;

        if ($total_data_shown == 0) {
            $index_from = -1;
            $index_to = -1;
        }


        $result = [
            "info" => "OK",
            "page_no" => $page,
            "data_per_page" => $limit,
            "total_data" => $total_data,
            "total_data_shown" => $total_data_shown,
            "index_from" => $index_from,
            "index_to" => $index_to,
            "data" => $products_data
        ];

        header('Content-Type: application/json');
        echo json_encode($result);

    }
