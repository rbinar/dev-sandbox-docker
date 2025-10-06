<?php
header('Content-Type: text/html; charset=UTF-8');

$uploadDir = '/tmp/uploads/';

// URL scanning functionality
if (isset($_POST['scan_url'])) {
    $url = trim($_POST['scan_url']);
    
    if (empty($url)) {
        die('<div class="results infected">❌ URL boş olamaz</div>');
    }
    
    if (!filter_var($url, FILTER_VALIDATE_URL) || !preg_match('/^https?:\/\//', $url)) {
        die('<div class="results infected">❌ Geçersiz URL formatı (http:// veya https:// gerekli)</div>');
    }
    
    echo '<div class="results scanning">';
    echo '<h3>🌐 URL Tarama Sonucu</h3>';
    echo '<div style="margin: 15px 0;">';
    echo '<div style="color: #666; margin: 10px 0; padding: 10px; background: #f9f9f9; border-radius: 4px;">';
    echo '🔗 <strong>URL:</strong> ' . htmlspecialchars($url);
    echo '</div>';
    
    // Download file from URL
    $downloadResult = downloadFileFromUrl($url, $uploadDir);
    
    if ($downloadResult['success']) {
        $filePath = $downloadResult['file_path'];
        $fileName = $downloadResult['file_name'];
        $fileSize = $downloadResult['file_size'];
        
        echo '<div style="color: #4caf50; margin: 8px 0; padding: 10px; background: #e8f5e8; border-radius: 4px;">';
        echo '✅ Dosya başarıyla indirildi (' . formatBytes($fileSize) . ')';
        echo '</div>';
        
        // Scan the downloaded file
        $scanResult = scanSingleFile($filePath, $fileName);
        echo $scanResult;
        
        // Clean up
        unlink($filePath);
    } else {
        echo '<div style="color: #f44336; margin: 8px 0; padding: 10px; background: #ffebee; border-radius: 4px;">';
        echo '❌ İndirme hatası: ' . htmlspecialchars($downloadResult['error']);
        echo '</div>';
    }
    
    echo '</div></div>';
    
    // Get ClamAV info
    exec('docker exec sandbox-antivirus clamscan --version 2>&1', $versionOutput);
    if (!empty($versionOutput)) {
        echo '<div style="background: #f5f5f5; padding: 15px; margin: 15px 0; border-radius: 6px; font-family: monospace; font-size: 12px;">';
        echo '<strong>🛡️ ClamAV Engine:</strong><br>';
        echo htmlspecialchars($versionOutput[0]);
        echo '</div>';
    }
    
    exit;
}

// File upload functionality
if ($_SERVER['REQUEST_METHOD'] !== 'POST' || !isset($_FILES['files'])) {
    die('<div class="results infected">❌ Geçersiz istek</div>');
}
$totalFiles = count($_FILES['files']['name']);
$infectedCount = 0;
$cleanCount = 0;
$errorCount = 0;

echo '<div class="results scanning">';
echo '<h3>🔍 Tarama Sonuçları (' . $totalFiles . ' dosya)</h3>';
echo '<div style="margin: 15px 0;">';

for ($i = 0; $i < $totalFiles; $i++) {
    if ($_FILES['files']['error'][$i] !== UPLOAD_ERR_OK) {
        echo '<div style="color: #f44336; margin: 5px 0;">❌ ' . htmlspecialchars($_FILES['files']['name'][$i]) . ' - Upload hatası</div>';
        $errorCount++;
        continue;
    }
    
    $fileName = basename($_FILES['files']['name'][$i]);
    $uploadPath = $uploadDir . uniqid() . '_' . $fileName;
    
    if (move_uploaded_file($_FILES['files']['tmp_name'][$i], $uploadPath)) {
        // Copy file to antivirus container and scan
        $containerPath = '/tmp/scan/' . basename($uploadPath);
        $copyCmd = 'docker cp ' . escapeshellarg($uploadPath) . ' sandbox-antivirus:' . escapeshellarg($containerPath) . ' 2>&1';
        $scanCmd = 'docker exec sandbox-antivirus clamscan ' . escapeshellarg($containerPath) . ' 2>&1';
        
        exec($copyCmd, $copyOutput, $copyReturn);
        
        if ($copyReturn === 0) {
            exec($scanCmd, $scanOutput, $scanReturn);
            $scanResult = implode("\n", $scanOutput);
            
            if (strpos($scanResult, 'FOUND') !== false) {
                echo '<div style="color: #f44336; margin: 8px 0; padding: 10px; background: #ffebee; border-radius: 4px;">';
                echo '🦠 <strong>' . htmlspecialchars($fileName) . '</strong> - <span style="color: #d32f2f;">VİRÜS TESPİT EDİLDİ!</span>';
                if (preg_match('/: (.+) FOUND/', $scanResult, $matches)) {
                    echo '<br><small style="color: #666;">Virüs türü: ' . htmlspecialchars($matches[1]) . '</small>';
                }
                echo '</div>';
                $infectedCount++;
            } elseif (strpos($scanResult, 'OK') !== false) {
                echo '<div style="color: #4caf50; margin: 8px 0; padding: 10px; background: #e8f5e8; border-radius: 4px;">';
                echo '✅ <strong>' . htmlspecialchars($fileName) . '</strong> - <span style="color: #2e7d32;">Temiz</span>';
                
                // Extract scan info
                if (preg_match('/Scanned files: (\d+)/', $scanResult, $matches)) {
                    echo '<br><small style="color: #666;">Tarama detayı: ' . $matches[1] . ' dosya kontrol edildi</small>';
                }
                echo '</div>';
                $cleanCount++;
            } else {
                echo '<div style="color: #ff9800; margin: 8px 0; padding: 10px; background: #fff3e0; border-radius: 4px;">';
                echo '⚠️ <strong>' . htmlspecialchars($fileName) . '</strong> - Tarama hatası';
                echo '<br><small style="color: #666;">' . htmlspecialchars(substr($scanResult, 0, 200)) . '</small>';
                echo '</div>';
                $errorCount++;
            }
        } else {
            echo '<div style="color: #f44336; margin: 8px 0; padding: 10px; background: #ffebee; border-radius: 4px;">';
            echo '❌ <strong>' . htmlspecialchars($fileName) . '</strong> - Container kopyalama hatası';
            echo '</div>';
            $errorCount++;
        }
        
        // Clean up
        unlink($uploadPath);
        exec('docker exec sandbox-antivirus rm -f ' . escapeshellarg($containerPath) . ' 2>/dev/null');
    } else {
        echo '<div style="color: #f44336; margin: 8px 0; padding: 10px; background: #ffebee; border-radius: 4px;">';
        echo '❌ <strong>' . htmlspecialchars($fileName) . '</strong> - Dosya yükleme hatası';
        echo '</div>';
        $errorCount++;
    }
}

echo '</div>';

// Summary
echo '<hr style="margin: 20px 0; border: none; height: 1px; background: #ddd;">';
echo '<div style="font-weight: bold; text-align: center; padding: 15px; background: #f9f9f9; border-radius: 6px;">';
echo '📊 Özet: ' . $totalFiles . ' dosya tarandı<br>';
echo '<span style="color: #4caf50;">✅ ' . $cleanCount . ' temiz</span> • ';
echo '<span style="color: #f44336;">🦠 ' . $infectedCount . ' virüs</span>';
if ($errorCount > 0) {
    echo ' • <span style="color: #ff9800;">⚠️ ' . $errorCount . ' hata</span>';
}
echo '</div>';

// Final message
if ($infectedCount > 0) {
    echo '<div style="background: #ffebee; border: 2px solid #f44336; padding: 20px; margin: 20px 0; border-radius: 8px; color: #c62828; text-align: center;">';
    echo '<strong>⚠️ GÜVENLİK UYARISI</strong><br>';
    echo 'Virüs tespit edildi! Bu dosyalar izole container içinde tarandı.<br>';
    echo 'Ana sisteminize hiçbir zarar verilmedi.';
    echo '</div>';
} else if ($cleanCount > 0) {
    echo '<div style="background: #e8f5e8; border: 2px solid #4caf50; padding: 20px; margin: 20px 0; border-radius: 8px; color: #2e7d32; text-align: center;">';
    echo '<strong>✅ TÜM DOSYALAR TEMİZ</strong><br>';
    echo 'Hiçbir virüs tespit edilmedi. Dosyalarınız güvenli.';
    echo '</div>';
}

echo '</div>';

// Get ClamAV info
exec('docker exec sandbox-antivirus clamscan --version 2>&1', $versionOutput);
if (!empty($versionOutput)) {
    echo '<div style="background: #f5f5f5; padding: 15px; margin: 15px 0; border-radius: 6px; font-family: monospace; font-size: 12px;">';
    echo '<strong>🛡️ ClamAV Engine:</strong><br>';
    echo htmlspecialchars($versionOutput[0]);
    echo '</div>';
}

// Function to download file from URL
function downloadFileFromUrl($url, $uploadDir) {
    $maxFileSize = 100 * 1024 * 1024; // 100MB
    $timeout = 30; // 30 seconds
    
    // Create unique filename
    $urlInfo = parse_url($url);
    $originalFileName = basename($urlInfo['path']);
    if (empty($originalFileName) || strpos($originalFileName, '.') === false) {
        $originalFileName = 'downloaded_file.bin';
    }
    
    $tempFileName = uniqid() . '_' . $originalFileName;
    $tempFilePath = $uploadDir . $tempFileName;
    
    // Initialize cURL
    $ch = curl_init();
    
    curl_setopt_array($ch, [
        CURLOPT_URL => $url,
        CURLOPT_RETURNTRANSFER => false,
        CURLOPT_FOLLOWLOCATION => true,
        CURLOPT_MAXREDIRS => 5,
        CURLOPT_TIMEOUT => $timeout,
        CURLOPT_CONNECTTIMEOUT => 10,
        CURLOPT_USERAGENT => 'ClamAV-Scanner/1.0 (Security Scanner)',
        CURLOPT_SSL_VERIFYPEER => true,
        CURLOPT_SSL_VERIFYHOST => 2,
        CURLOPT_WRITEFUNCTION => function($ch, $data) use ($tempFilePath, $maxFileSize) {
            static $fp = null;
            static $totalSize = 0;
            
            if ($fp === null) {
                $fp = fopen($tempFilePath, 'wb');
                if (!$fp) {
                    return 0; // Stop download
                }
            }
            
            $dataSize = strlen($data);
            $totalSize += $dataSize;
            
            if ($totalSize > $maxFileSize) {
                fclose($fp);
                unlink($tempFilePath);
                return 0; // Stop download - file too large
            }
            
            return fwrite($fp, $data);
        }
    ]);
    
    $result = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $error = curl_error($ch);
    $fileSize = curl_getinfo($ch, CURLINFO_SIZE_DOWNLOAD);
    curl_close($ch);
    
    if ($result === false || !empty($error)) {
        if (file_exists($tempFilePath)) unlink($tempFilePath);
        return ['success' => false, 'error' => 'cURL hatası: ' . $error];
    }
    
    if ($httpCode >= 400) {
        if (file_exists($tempFilePath)) unlink($tempFilePath);
        return ['success' => false, 'error' => 'HTTP ' . $httpCode . ' hatası'];
    }
    
    if (!file_exists($tempFilePath) || filesize($tempFilePath) == 0) {
        if (file_exists($tempFilePath)) unlink($tempFilePath);
        return ['success' => false, 'error' => 'Dosya indirilemedi veya boş'];
    }
    
    if (filesize($tempFilePath) > $maxFileSize) {
        unlink($tempFilePath);
        return ['success' => false, 'error' => 'Dosya çok büyük (Max: 100MB)'];
    }
    
    return [
        'success' => true,
        'file_path' => $tempFilePath,
        'file_name' => $originalFileName,
        'file_size' => filesize($tempFilePath)
    ];
}

// Function to scan a single file
function scanSingleFile($filePath, $fileName) {
    $containerPath = '/tmp/scan/' . basename($filePath);
    $copyCmd = 'docker cp ' . escapeshellarg($filePath) . ' sandbox-antivirus:' . escapeshellarg($containerPath) . ' 2>&1';
    $scanCmd = 'docker exec sandbox-antivirus clamscan ' . escapeshellarg($containerPath) . ' 2>&1';
    
    exec($copyCmd, $copyOutput, $copyReturn);
    
    if ($copyReturn !== 0) {
        return '<div style="color: #f44336; margin: 8px 0; padding: 10px; background: #ffebee; border-radius: 4px;">
                ❌ <strong>' . htmlspecialchars($fileName) . '</strong> - Container kopyalama hatası
                </div>';
    }
    
    exec($scanCmd, $scanOutput, $scanReturn);
    $scanResult = implode("\n", $scanOutput);
    
    // Clean up container file
    exec('docker exec sandbox-antivirus rm -f ' . escapeshellarg($containerPath) . ' 2>/dev/null');
    
    if (strpos($scanResult, 'FOUND') !== false) {
        $output = '<div style="color: #f44336; margin: 8px 0; padding: 10px; background: #ffebee; border-radius: 4px;">';
        $output .= '🦠 <strong>' . htmlspecialchars($fileName) . '</strong> - <span style="color: #d32f2f;">VİRÜS TESPİT EDİLDİ!</span>';
        if (preg_match('/: (.+) FOUND/', $scanResult, $matches)) {
            $output .= '<br><small style="color: #666;">Virüs türü: ' . htmlspecialchars($matches[1]) . '</small>';
        }
        $output .= '</div>';
        
        $output .= '<div style="background: #ffebee; border: 2px solid #f44336; padding: 20px; margin: 20px 0; border-radius: 8px; color: #c62828; text-align: center;">';
        $output .= '<strong>⚠️ GÜVENLİK UYARISI</strong><br>';
        $output .= 'URL\'den indirilen dosyada virüs tespit edildi!<br>';
        $output .= 'Dosya izole container içinde tarandı ve silindi.';
        $output .= '</div>';
        
        return $output;
    } elseif (strpos($scanResult, 'OK') !== false) {
        $output = '<div style="color: #4caf50; margin: 8px 0; padding: 10px; background: #e8f5e8; border-radius: 4px;">';
        $output .= '✅ <strong>' . htmlspecialchars($fileName) . '</strong> - <span style="color: #2e7d32;">Temiz</span>';
        
        if (preg_match('/Scanned files: (\d+)/', $scanResult, $matches)) {
            $output .= '<br><small style="color: #666;">Tarama detayı: ' . $matches[1] . ' dosya kontrol edildi</small>';
        }
        $output .= '</div>';
        
        $output .= '<div style="background: #e8f5e8; border: 2px solid #4caf50; padding: 20px; margin: 20px 0; border-radius: 8px; color: #2e7d32; text-align: center;">';
        $output .= '<strong>✅ DOSYA TEMİZ</strong><br>';
        $output .= 'URL\'den indirilen dosyada virüs tespit edilmedi.';
        $output .= '</div>';
        
        return $output;
    } else {
        return '<div style="color: #ff9800; margin: 8px 0; padding: 10px; background: #fff3e0; border-radius: 4px;">
                ⚠️ <strong>' . htmlspecialchars($fileName) . '</strong> - Tarama hatası
                <br><small style="color: #666;">' . htmlspecialchars(substr($scanResult, 0, 200)) . '</small>
                </div>';
    }
}

// Function to format file size
function formatBytes($bytes, $precision = 2) {
    $units = array('B', 'KB', 'MB', 'GB', 'TB');
    
    for ($i = 0; $bytes > 1024 && $i < count($units) - 1; $i++) {
        $bytes /= 1024;
    }
    
    return round($bytes, $precision) . ' ' . $units[$i];
}
?>