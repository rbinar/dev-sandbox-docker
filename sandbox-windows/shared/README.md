# Windows-Host Dosya Paylaşımı

Bu klasör Windows container'ı ile host sistem arasında dosya paylaşımı için kullanılır.

## Kullanım

### Host'tan Windows'a dosya gönderme:
1. Dosyayı bu `shared/` klasörüne kopyalayın
2. Windows'ta `C:\Shared\` klasöründe görüntülenecek

### Windows'tan Host'a dosya gönderme:
1. Windows'ta dosyayı `C:\Shared\` klasörüne kaydedin
2. Bu `shared/` klasöründe görüntülenecek

## Güvenlik Notları
- Bu klasör Windows container'ı ile paylaşılır
- Sadece güvendiğiniz dosyaları paylaşın
- Virüslü dosyalar için antivirus sandbox'ını kullanın

## Örnekler
```
shared/
├── documents/     # Belgeler
├── software/      # Yazılım yükleyicileri  
├── images/        # Resimler
└── data/          # Veri dosyaları
```