import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  static Future<void> generateLegalPdf(String content, String lang) async {
    final pdf = pw.Document();
    
    // Load fonts asynchronously to reduce latency
    final font = lang == "Hindi" 
        ? await PdfGoogleFonts.notoSansDevanagariRegular() 
        : await PdfGoogleFonts.notoSansRegular();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => pw.Padding(
          padding: const pw.EdgeInsets.all(20),
          child: pw.Text(content, style: pw.TextStyle(font: font, fontSize: 12)),
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
}