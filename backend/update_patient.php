<?php
header("Content-Type: application/json");

require 'db_connection.php'; // Make sure to include your database connection here

$response = [
    "success" => false,
    "message" => "An error occurred while updating patient data."
];

// Check if the necessary POST parameters are present
if (isset($_POST['patientId']) && isset($_POST['name']) && isset($_POST['age']) && isset($_POST['mobile'])) {
    $patientId = $_POST['patientId'];
    $name = $_POST['name'];
    $age = $_POST['age'];
    $mobile = $_POST['mobile'];
    $imagePath = '';  // Initialize imagePath if no new image is provided

    // Check if an image file is provided and needs updating
    if (!empty($_POST['image_path'])) {
        // Define the directory where images will be saved
        $imageDir = 'uploads/patients/';
        
        // Create the directory if it doesn't exist
        if (!is_dir($imageDir)) {
            mkdir($imageDir, 0755, true);
        }
        
        // Create a unique filename using the patient ID and current timestamp
        $imageFileName = $imageDir . 'patient_' . $patientId . '_' . time() . '.jpg';
        
        // Decode the base64 image and save it to the server
        $imageData = base64_decode($_POST['image_path']);
        
        // Save the image
        if (file_put_contents($imageFileName, $imageData)) {
            $imagePath = $imageFileName;
        } else {
            $response["message"] = "Failed to save the image.";
            echo json_encode($response);
            exit;
        }
    }

    // Prepare the SQL query to update the patient's information
    $updateQuery = "UPDATE patients SET name = ?, age = ?, mobile = ?" . 
                   (!empty($imagePath) ? ", image_path = ?" : "") . " WHERE patientId = ?";

    $stmt = $conn->prepare($updateQuery);

    // Bind parameters based on whether imagePath is included or not
    if (!empty($imagePath)) {
        $stmt->bind_param("ssssi", $name, $age, $mobile, $imagePath, $patientId);
    } else {
        $stmt->bind_param("sssi", $name, $age, $mobile, $patientId);
    }

    // Execute the query and check if the update was successful
    if ($stmt->execute()) {
        $response["success"] = true;
        $response["message"] = "Patient information updated successfully.";
    } else {
        $response["message"] = "Failed to update patient information.";
    }

    $stmt->close();
} else {
    $response["message"] = "Incomplete request. Please provide all required data.";
}

// Output the response in JSON format
echo json_encode($response);
$conn->close();
?>
