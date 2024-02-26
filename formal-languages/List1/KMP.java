import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

// Complexity of KMP algorithm is 0(n + m) in the worst case
public class KMP {
  // Złozoność czasowa przetw.wstępne 0(m), wyszukiwanie 0(n), gdzie m to długość wzorca, a n to długość tekstu 

  public static void main(String[] args) {
    String wzorzec = args[0];
    // String path = args[1];
    // System.out.println("Size wzorca to " + wzorzec.length());

    List<Character> pattern = new ArrayList<>();
    List<Character> text = new ArrayList<>();
    String path = "./test.txt";

    for(char litera : wzorzec.toCharArray()) {
      pattern.add(litera);
    }

    // Wczytanie tekstu z pliku
    try { 
      InputStreamReader czytnik = new InputStreamReader(new FileInputStream(path), StandardCharsets.UTF_8);
      int znak;
      while((znak = czytnik.read()) != -1) {
        char litera = (char) znak;
        text.add(litera);
      }
      czytnik.close();
    } catch(IOException ex) {
      ex.printStackTrace();
    }

    System.out.println(text.size());
    List<Integer> results = kmp_search(pattern, text);
    
    if(results.size() > 0) {
      for(int index : results) {
        System.out.print(index + " ");
      }
    } else {
      System.out.println("Nie znaleziono patternu");
    }
  }

  public static void preprocess_lps(int[] lps, List<Character> pattern) {
    lps[0] = 0;
    int k = 1; // aktualna pozycja w tablicy lps
    int l = 0; // indeks listy pattern, w której ma być umieszczona kolejna litera szukanego ciągu znaków
    // Algorytm budowania tabeli longest prefix suffix
    while(k < pattern.size()) {
      if(pattern.get(k) == pattern.get(l)) { 
        l++;
        lps[k] = l;
        k++;
      } else { 
        if(l > 0) {
          l = lps[l - 1];
        } else { // l == 0
          lps[k] = 0;
          k++;
        }
      }
    }
  }

  // Ideą jest to zeby unikac dopasowywania znaków o których wiadomo ze i tak będą pasować
  public static List<Integer> kmp_search(List<Character> W, List<Character> S) {
    List<Integer> indexes = new ArrayList<>();
    int i = 0; // indeks aktualnie rozpatrywanego znaku wewnątrz W
    int m = 0; // pozycja w tekście, od której rozpoczyna się aktualne częściowe dopasowanie
    int[] lps = new int[W.size()];
    preprocess_lps(lps, W);

    while(m < S.size()) {
      System.out.println(m);
      if(W.get(i).equals(S.get(m))) {  
        System.out.println("Match");
        i++; 
        m++;
        if(i == W.size()) {
          indexes.add(m - i);
          m = m - i + 1;
          i = 0;
        }
      } 
      else {
        System.out.println("Mismatch");
        if(i != 0) {
          i = lps[i - 1];
        }
        else {
          m++;
        }
      }
    }
    return indexes;
  }
}
