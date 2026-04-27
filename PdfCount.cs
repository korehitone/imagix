using System;
using System.Threading.Tasks;
using Windows.Storage;
using Windows.Data.Pdf;
class Program {
  static void Main(string[] args) {
    var file = StorageFile.GetFileFromPathAsync(args[0]).AsTask().GetAwaiter().GetResult();
    var pdf = PdfDocument.LoadFromFileAsync(file).AsTask().GetAwaiter().GetResult();
    Console.WriteLine("PAGES=" + pdf.PageCount);
  }
}
