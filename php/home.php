<?php
require 'dbh.php'; // Assume dbh.php contains the PDO connection setup

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Content-Type: application/json');

// Handle preflight request for OPTIONS method
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Enable error reporting for debugging purposes (optional in production)
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Get the request method
$method = $_SERVER['REQUEST_METHOD'];

// Handle different HTTP methods for CRUD operations
switch ($method) {
    case 'GET':
        handleGetPatients();
        break;

    case 'POST':
        $data = json_decode(file_get_contents("php://input"), true);
        handleAddPatient($data);
        break;

    case 'PUT':
        $data = json_decode(file_get_contents("php://input"), true);
        handleEditPatient($data);
        break;

    case 'DELETE':
        $data = json_decode(file_get_contents("php://input"), true);
        handleDeletePatient($data);
        break;

    default:
        http_response_code(405); // Method not allowed
        echo json_encode(['success' => false, 'message' => 'Unsupported request method']);
        break;
}

// Function to retrieve all patients
function handleGetPatients() {
    global $conn;
    try {
        $stmt = $conn->query("SELECT * FROM patients");
        $patients = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo json_encode(['success' => true, 'patients' => $patients]);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['success' => false, 'message' => 'Error fetching patients: ' . $e->getMessage()]);
    }
}

// Function to add a new patient
function handleAddPatient($data) {
    global $conn;

    // Validate the input
    $name = validateInput($data['name'] ?? '', 'name');
    $age = validateInput($data['age'] ?? '', 'age');
    $mobile = validateInput($data['mobile'] ?? '', 'mobile');
    $spermCount = validateInput($data['spermCount'] ?? '', 'spermCount');
    $image = $data['image'] ?? '';

    if (!$name || !$age || !$mobile || !$spermCount) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'All fields are required']);
        return;
    }

    // Handle image upload if provided
    $imagePath = null;
    if (!empty($image)) {
        $imagePath = saveImage($image);
        if (!$imagePath) {
            http_response_code(500);
            echo json_encode(['success' => false, 'message' => 'Error uploading image']);
            return;
        }
    }

    try {
        $stmt = $conn->prepare("INSERT INTO patients (name, age, mobile, sperm_count, image) VALUES (:name, :age, :mobile, :sperm_count, :image)");
        $stmt->bindParam(':name', $name);
        $stmt->bindParam(':age', $age);
        $stmt->bindParam(':mobile', $mobile);
        $stmt->bindParam(':sperm_count', $spermCount);
        $stmt->bindParam(':image', $imagePath); // Store the path of the image

        if ($stmt->execute()) {
            http_response_code(201); // Created
            echo json_encode(['success' => true, 'message' => 'Patient added successfully']);
        } else {
            http_response_code(500); // Internal server error
            echo json_encode(['success' => false, 'message' => 'Error adding patient']);
        }
    } catch (PDOException $e) {
        http_response_code(500); // Internal server error
        echo json_encode(['success' => false, 'message' => 'Database error occurred: ' . $e->getMessage()]);
    }
}

// Function to save image to the server
function saveImage($base64String) {
    $image = base64_decode($base64String);
    
    // Check image size and format (optional for security)
    if (strlen($image) > 5000000) { // 5MB limit
        return false; // Fail if image is too large
    }

    $imagePath = 'uploads/' . uniqid() . '.png'; // Save as a unique PNG file
    
    // Create the uploads directory if it doesn't exist
    if (!is_dir('uploads')) {
        mkdir('uploads', 0777, true);
    }
    
    // Save the image to the specified path
    if (file_put_contents($imagePath, $image) !== false) {
        return $imagePath; // Return the path of the saved image
    }
    return false; // Return false if saving fails
}

// Function to edit an existing patient
function handleEditPatient($data) {
    global $conn;

    // Validate the input
    $id = validateInput($data['id'] ?? '', 'id');
    $name = validateInput($data['name'] ?? '', 'name');
    $age = validateInput($data['age'] ?? '', 'age');
    $mobile = validateInput($data['mobile'] ?? '', 'mobile');
    $spermCount = validateInput($data['spermCount'] ?? '', 'spermCount');
    $image = $data['image'] ?? ''; // Optional image update

    if (!$id || !$name || !$age || !$mobile || !$spermCount) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'All fields are required']);
        return;
    }

    // Handle image upload if provided
    $imagePath = null;
    if (!empty($image)) {
        $imagePath = saveImage($image);
        if (!$imagePath) {
            http_response_code(500);
            echo json_encode(['success' => false, 'message' => 'Error uploading image']);
            return;
        }
    }

    try {
        $query = "UPDATE patients SET name = :name, age = :age, mobile = :mobile, sperm_count = :sperm_count";
        if ($imagePath) {
            $query .= ", image = :image"; // Only update image if provided
        }
        $query .= " WHERE id = :id";

        $stmt = $conn->prepare($query);
        $stmt->bindParam(':id', $id);
        $stmt->bindParam(':name', $name);
        $stmt->bindParam(':age', $age);
        $stmt->bindParam(':mobile', $mobile);
        $stmt->bindParam(':sperm_count', $spermCount);
        if ($imagePath) {
            $stmt->bindParam(':image', $imagePath);
        }

        if ($stmt->execute()) {
            http_response_code(200);
            echo json_encode(['success' => true, 'message' => 'Patient updated successfully']);
        } else {
            http_response_code(500);
            echo json_encode(['success' => false, 'message' => 'Error updating patient']);
        }
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['success' => false, 'message' => 'Database error occurred: ' . $e->getMessage()]);
    }
}

// Function to delete a patient by ID
function handleDeletePatient($data) {
    global $conn;
    $id = validateInput($data['id'] ?? '', 'id');

    if (!$id) {
        http_response_code(400); // Bad request
        echo json_encode(['success' => false, 'message' => 'Patient ID is required']);
        return;
    }

    try {
        $stmt = $conn->prepare("DELETE FROM patients WHERE id = :id");
        $stmt->bindParam(':id', $id);

        if ($stmt->execute()) {
            http_response_code(200); // OK
            echo json_encode(['success' => true, 'message' => 'Patient deleted successfully']);
        } else {
            http_response_code(500); // Internal server error
            echo json_encode(['success' => false, 'message' => 'Error deleting patient']);
        }
    } catch (PDOException $e) {
        http_response_code(500); // Internal server error
        echo json_encode(['success' => false, 'message' => 'Database error occurred: ' . $e->getMessage()]);
    }
}

// Function to validate input
function validateInput($input, $type) {
    $input = trim($input);
    if (empty($input)) {
        return false;
    }

    // You can add more validation based on the type
    switch ($type) {
        case 'name':
        case 'mobile':
            if (!preg_match("/^[a-zA-Z0-9\s]+$/", $input)) {
                return false;
            }
            break;
        case 'age':
        case 'spermCount':
            if (!is_numeric($input) || (int)$input < 0) {
                return false; // Ensure age and spermCount are non-negative integers
            }
            break;
        case 'id':
            if (!is_numeric($input)) {
                return false;
            }
            break;
        default:
            break;
    }

    return $input;
}
?>
