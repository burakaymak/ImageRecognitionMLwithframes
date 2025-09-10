# 📦 ML Image Recognition with Bounding Boxes

Bu proje, **YOLOv3** modeli ile görseller üzerinde nesne tanıma (object detection) gerçekleştiren bir iOS uygulamasıdır.  
Kullanıcı bir fotoğraf seçtiğinde model, görseldeki nesneleri tespit eder, her nesne için **bounding box** (kutucuk) çizer ve tahmin edilen sınıf ismini güven yüzdesi ile birlikte gösterir.  

---

## ✨ Özellikler
- 📸 Kullanıcının galeriden fotoğraf seçmesine izin verir  
- 🤖 **YOLOv3 CoreML modeli** ile nesne tanıma  
- 🟩 Tespit edilen nesnelerin etrafına **kutucuk çizimi**  
- 🏷️ Nesne ismi + güven yüzdesi (confidence) ekranda gösterilir  
- 📐 Görsel oranlarına göre kutuların doğru konumda çizilmesi (letterbox fix)  

---

## 🛠 Kullanılan Yapılar
- **UIKit** → Görsel seçimi (`UIImagePickerController`) ve UI  
- **CoreML** → YOLOv3 modelini çalıştırmak için  
- **Vision (VNCoreMLRequest & VNRecognizedObjectObservation)** → Nesne tespit süreci  
- **CALayer & CATextLayer** → Bounding box ve label çizimleri  
- **DispatchQueue** → Model tahmini için background thread, UI için main thread  

---

## ⚙️ Çalışma Mantığı
1. Kullanıcı galeriden bir görsel seçer.  
2. `CIImage` formatına dönüştürülür.  
3. `VNCoreMLRequest` ile YOLOv3 modeli çalıştırılır.  
4. Model çıktısı → `[VNRecognizedObjectObservation]` nesneleri döner.  
5. Her gözlem için:  
   - `boundingBox` bilgisi hesaplanır  
   - `convertBoundingBox()` ile UIKit koordinat sistemine dönüştürülür  
   - Üstüne **yeşil kutu** çizilir  
   - Confidence yüzdesi ve sınıf ismi `CATextLayer` ile gösterilir  

---

## 📐 Bounding Box Dönüşümü
Vision koordinatları **[0,1] normalized space**’te gelir.  
Bunun için:
- ImageView ile görselin oranları karşılaştırılır  
- Ölçekleme (`scaleX`, `scaleY`) yapılır  
- Letterboxing boşlukları (`xOffset`, `yOffset`) hesaplanır  
- UIKit koordinat sistemine uygun hale dönüştürülür  

```swift
func convertBoundingBox(_ boundingBox: CGRect, to imageView: UIImageView) -> CGRect { ... }


