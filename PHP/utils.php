<?php
    class Utils {

        public $fail_message;
        private $invalid_files_data;


        public function __construct() {

            $this->fail_message = "";
            $this->invalid_files_data = [];

        }


        public function invalidFilesData() {
            return $this->invalid_files_data;
        }


        public function createJsonFile($full_path_filename, $data, $showStatus) {
            $this->fail_message = "";

            $fp = fopen($full_path_filename, "w", true);

            try {
                // if (file_put_contents($full_path_filename, json_encode($data))) {
                    // echo $full_path_filename . " created successfully";
                // }
                
                fwrite($fp, json_encode($data, JSON_PRETTY_PRINT));

                if ($showStatus) {
                    echo "$full_path_filename created successfully <br>";
                }
                
            } catch (Exception $e) {
                echo "Failed to create json file: $e";
                $this->fail_message = "Failed to create JSON file: $e";
                return;
            } 
            finally {
                fclose($fp);
            }
        }

        public function updateSellerProductCountJson($json_file_location, $new_product_count_value) {
            $this->fail_message = "";

            try {
                $jsonString = file_get_contents($json_file_location);
                $data = json_decode($jsonString, true);

                $data["total_product"] = $new_product_count_value; // update the value in "total_product" key
                $this->createJsonFile($json_file_location, $data, false); 
                // echo "$json_file_location edited successfully <br>";
            } catch (Exception $e) {
                echo "Failed to edit json file: $e";
                $this->fail_message = "Failed to edit JSON file: $e";
                return;
            } 
        }

        public function getLastSellerProductCount($json_file_location) {
            // get the last product count in seller data history (json file)

            $this->fail_message = "";

            try {
                $jsonString = file_get_contents($json_file_location);
                $data = json_decode($jsonString, true);

                return $data["total_product"];
            } catch (Exception $e) {
                echo "Failed to get last seller product count <br>";
                $this->fail_message = "Failed to get last seller product count";
                return;
            }
        }

        public function removeDirectory($path) {
            // source: https://stackoverflow.com/a/49444840/22171100
             
            $files = glob($path . '/*');
            foreach ($files as $file) {
                is_dir($file) ? $this->removeDirectory($file) : unlink($file);
            }
            
            rmdir($path);
            return;
        }

        // =============================== function for file validation ==============================
        // <!-- referensi: https://www.youtube.com/watch?v=KXyMpRp4d2Q -->

        /*
            <!-- <form action="" method="POST" enctype="multipart/form-data"> -->
            <!-- <input type="file" name="userfile"> -->
            <!-- <input type="file" name="userfile[]" multiple=""> -->
            <!-- <input type="submit" name="Upload"> -->
            <!-- </form> -->
        */

        private $phpFileUploadInfo = array(
            0 => "There is no error, the file uploaded with success <br>",
            1 => "The upload file exceeds the upload_max_filesize directive in php.ini <br>",
            2 => "The upload file exceeds the MAX_FILE_SIZEdirective that was specified in the HTML form <br>",
            3 => "The upload file was only partially uploaded <br>",
            4 => "No file was uploaded <br>",
            6 => "Missing a temporary folder <br>",
            7 => "Failed to write file to disk <br>",
            8 => "A PHP extention stopped the file upload. <br>",
        );
    
        // for better array readability
        private function pre_r($array) {
            echo "<pre>";
            print_r($array);
            echo "</pre>";
        }
    
        public function reArrayFiles($file_post) {
            $file_ary = array();
            $file_count = count($file_post['name']);
            $file_keys = array_keys($file_post);
    
            for ($i = 0; $i < $file_count; $i++) {
                foreach ($file_keys as $key) {
                    $file_ary[$i][$key] = $file_post[$key][$i];
                }
            }

            return $file_ary;
    
            // contoh: 
            // $file_array = reArrayFiles($_FILES["userfile]);
            // print_r($file_array);
        }

        public function isValidInteger($value) {
            // make sure $value type is a string

            $integer_data = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];

            for ($i = 0; $i < strlen($value); $i++) {

                if ( !in_array($value[$i], $integer_data) ) {
                    return false;
                }        

            }

            return true;
        }

        public function filesValidator($data, $allowed_extention, $max_file_size) {
            $this->fail_message = "";
            $file_array = $this->reArrayFiles($data);
            $new_data_count = count($file_array);
            $data_index = 0;
            $valid_file = [];
            $invalid_files_data = [];

            // print_r($file_array);

            // $ALLOWED_EXTENSION = array("jpg", "png", "gif", "jpeg");
            // $MAX_FILE_SIZE = 153600; // approx 150 kb max size

            for ($i = 0; $i < $new_data_count; $i++) {
                $filename = $file_array[$i]["name"];
                $is_valid = true;

                if ($file_array[$i]["error"]) {
                    // echo $filename . " - " . $phpFileUploadInfo[$file_array[$i]["error"]];
                    $this->fail_message = $filename . " - " . $phpFileUploadInfo[$file_array[$i]["error"]];
                    $is_valid = false;
                }
                else {
                    // extract the actual extension file
                    $file_ext = explode(".", $filename); // pisah nama dan ekstensi file antara dot (titik)
                    // print_r($file_ext);
                    $file_ext = strtolower(end($file_ext)); // ambil array yang terakhir, yaitu ekstensi file
                    // echo $file_ext;

                    if (!in_array($file_ext, $allowed_extention)) {
                        // echo "$filename - Invalid file extension <br>";
                        $this->fail_message = "$filename - Invalid file extension";
                        $is_valid = false;
                    }
                    else if ($file_array[$i]["size"] > $max_file_size) {
                        // echo "$filename size is more than " . $max_file_size / 1024 . "kb <br>";
                        $this->fail_message = "$filename size is more than " . $max_file_size / 1024 . "kb";
                        $is_valid = false;
                    }
                    
                }


                if ($is_valid) {
                    
                    // collect valid file/image
                    $valid_file[$data_index] = [
                        // "fullpath_image_name" => $full_path_filename,
                        "filename" => $filename,
                        "image_file" => $file_array[$i]["tmp_name"]
                    ];

                    $data_index++;
                }
                else {
                    $this->invalid_files_data[$filename] = $this->fail_message;
                }
            }

            // var_dump($invalid_files_data);

            

            return $valid_file;
        }

        public function sendErrorResponse($msg) {
            $error_msg = $msg;
            echo "fail msg: " . $this->fail_message === "" ? "empty" : $this->fail_message;
    
            if (!empty($this->fail_message)) {

                if ($msg !== $this->fail_message) {
                    $error_msg = $error_msg . " - " . $this->fail_message;
                }
                
            }
    
            if (!empty($error_msg)) {
                $result = [
                    "info" => "NOT OK",
                    "error_msg" => $error_msg
                ];
    
                $this->fail_message = "";
        
                header('Content-Type: application/json');
                echo json_encode($result);
                return exit;
            }
        }
    }
?>
