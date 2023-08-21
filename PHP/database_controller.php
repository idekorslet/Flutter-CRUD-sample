<?php
    require_once "connection.php";

    
    class DatabaseController {

        private $is_data_updated = false;
        public $total_data_deleted = 0;
        public $last_inserted_id = 0;

        public function isUpdateDataOk() {
            return $this->is_data_updated;
        }


        public function insertData($connection, $data, $sql) {
            try {
                // $sql = "INSERT INTO products (seller_id, title, description, price, stock) VALUES (?, ?, ?, ?, ?)";
    
                // $data = array(
                //     [22, "baju", "baju kerja", 100000, 10],
                //     [22, "baju", "sepatu sekolah", 100000, 10],
                //     [21, "baju", "tas sekolah", 100000, 10],         
                // );

                $this->inserted_data = 0;
                $this->executed_count = 0;

                $statement = $connection->prepare($sql);
                $connection->beginTransaction();
                
                foreach ($data as $row) {
                    $this->executed_count++;
                    $statement->execute($row);
                }

                $this->inserted_data = $this->executed_count;
                
                $this->last_inserted_id = $connection->lastInsertId();
                // echo $this->last_inserted_id;
                // var_dump($this->last_inserted_id);
                $connection->commit();
            } catch (Exception $e) {
                $this->inserted_data = 0;
                $connection->rollback();
                echo "Failed to insert data: $e";
                return;
            }
            finally {
                // echo "Total data inserted: $inserted_data ";
                // echo "Total executed: $executed_count <br>";
                $connection = null;
            }
        }

        public function updateData($connection, $data, $sql) {

            try {
                $statement = $connection->prepare($sql);
                // echo $statement->debugDumpParams();
                // echo $statement->queryString;
                $statement->execute($data);
                $this->is_data_updated = $statement->rowCount() > 0;
                // echo $statement->rowCount() . " row affected | $is_data_updated <br>";
            } catch (Exception $e) {
                echo "Failed to update product: $e";
                return;
            }
            finally {
                $connection = null;
            }
        }


        public function selectData($connection, $sql, $close=true) {
            $result = [];

            try {
                $statement = $connection->prepare($sql);
                $statement->execute();
                // return $get_total_data ? $statement->fetchAll() : $statement->fetchColumn();
                $result = $statement->fetchAll();
            } catch (Exception $e) {
                echo "Failed to get data @selectData function: $e";
            }
            finally {
                if ($close) {
                    $connection = null;
                }
            }

            return $result;
        }


        public function deleteData($connection, $sql) {

            $this->total_data_deleted = 0;

            try {
                $statement = $connection->prepare($sql);
                $statement->execute();
                // echo $statement->rowCount() . " data deleted <br>";
                $this->total_data_deleted = $statement->rowCount();
            } catch (Exception $e) {
                echo "Failed to delete data: $e";
                return;
            }
            finally {
                $connection = null;
            }
        }

        public function getValidToken($connection, $seller_id): String 
        {
            $sql_token = "SELECT token FROM sellers WHERE seller_id = $seller_id";
            $result = $this->selectData($connection, $sql_token)[0]; // ambil data yang pertama/index ke-0
            return $result["token"];
        }

    }

    // $db_controller = new DatabaseController();

    // $sql = "INSERT INTO sellers (seller_name, registered_at, token, location, email) VALUES (?, ?, ?, ?, ?)";
    // $data = array(
    //     ["dodo", "2022-10-20 10:00:15", "seller1-token", "Jakarta", "seller1@gmail.com"],
    //     ["udin", "2022-10-20 10:00:15", "seller2-token", "Surabaya", "seller2@gmail.com"]
    // );
    // $db_controller->insertData($connection, $data, $sql);

    // $sql = "INSERT INTO products (seller_id, title, description, price, stock) VALUES (?, ?, ?, ?, ?)";
    // $data = array(
    //     [22, "baju", "baju kerja", 100000, 10],
    //     [22, "baju", "baju sekolah", 100000, 10],
    //     [21, "baju", "sepatu sekolah", 100000, 10],         
    // );
    // $db_controller->insertData($connection, $data, $sql);
