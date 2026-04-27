using System;
using System.Threading.Tasks;
using Windows.Foundation;
using Windows.Storage;
using Windows.Data.Pdf;
public static class WinRtHelper {
  public static T Await<T>(IAsyncOperation<T> op) {
    return op.AsTask().GetAwaiter().GetResult();
  }
}
