import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

public class FA {

  // static int NO_OF_CHARS = 256;
  static int NO_OF_CHARS = 65523;
  // Badanie kazdego znaku w tekście tylko raz aby znaleźć pattern, więc liniowy czas na matchowanie 
  // Zdefiniowany przez M = {Q, Σ, q_0, A, σ}, gdzie 
  // Q - skończony zbiór stanów, Σ - skończony alfabet wejściowy, q_0 - stan początkowy, A - zbiór stanów akceptujących , σ - funkcja przejścia z Q x Σ -> Q
  // Algorytm efektywny bo kazdy znak w tekscie jest sprawdzany dokladnie raz, matchowanie to 0(n), gdzie n to dlugosc tekstu, mniej efektywny jezeli Σ jest duza 
  public static void main(String[] args) {
    String wzorzec = args[0];
    String path = args[1];
    List<Character> pattern = new ArrayList<>();
    List<Character> text = new ArrayList<>();
    // String path = "./tests-POLISH.txt";
    for(char litera : wzorzec.toCharArray()) {
      pattern.add(litera);
    }
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

    search(pattern, text);
  }

  // Przejście ze stanu q z char do nastepnego polega na zobaczeniu sciezki do q-1|char i znalezieniu najdluzszego prefixu patternu który jest równiez suffixem i na podstawie tego zobaczenie jaki stan jest następny 
  private static int countNextState(List<Character> pattern, int state, int k) {
    int next_state;
    int i;
    // char c jest taki sam jak następny w patternie, zwiekszenie stanu
    if(state < pattern.size() && k == pattern.get(state)) {
      return state + 1;      
    }
    // Pętla do znalezienia najdluzszego prefixu patternu ktory jest równiez suffixem
    for(next_state = state; next_state > 0; next_state--) {
      if(pattern.get(next_state - 1) == k) {
        for(i = 0; i < next_state - 1; i++) {
          if(pattern.get(i) != pattern.get(state - next_state + 1 + i)) {
            break;
          }
        }
        if(i == next_state - 1) {
          return next_state;
        }
      }
    }
    return 0;
  }

  // Złozoność czasowa func to O(M³|Σ|), M to dł. patternu, Σ to liczba wszystkich mozliwych char w patternie i tekście
  public static void computeTable(List<Character> pattern, int[][] table) {
    int pat_len = pattern.size();
    int state, k;
    for(state = 0; state <= pat_len; ++state) {
      for(k = 0; k < NO_OF_CHARS; ++k) {
        table[state][k] = countNextState(pattern, state, k);
      }
    }
  }

  // Automat startuje w stanie q_0 i czyta znaki ciągu wejściowego pojedynczo
  // Automat będąc w stanie q i czytając char a przenosi się ze stanu q do stanu σ(q, a), jezeli stan ten zawiera się w zbiorze A, to M zaakceptowała czytanie stringa
  public static void search(List<Character> pattern, List<Character> text) {
    List<Integer> indexes = new ArrayList<>();
    int n = text.size();
    int pat_len = pattern.size();
    int curr_state = 0;
    int i = 0;
    int[][] table = new int[pat_len + 1][NO_OF_CHARS];

    // Prepare Finite Automate Table
    computeTable(pattern, table);

    for(i = 0; i < n; i++) {
      curr_state = table[curr_state][text.get(i)];
      if(curr_state == pat_len) { // found match(curr state has a value of the length of pattern) 
        int index = i - pat_len + 1; // found index of a pattern
        indexes.add(index);
        // System.out.println(text.get(i));
        // System.out.println("Pattern found at index " + index);
        for(int l = 1; l <= pat_len; l++) {
          // if(text.get(i + l).equals(text.get(index + l))) {
          // }
          if(!text.get(i + l).equals(text.get(index + l))) {
            break;
          }
          if(l == pat_len) {
            // System.out.println("Finally");
            for(int j = pat_len - 1; j > 0; j--) {
              indexes.add(index + pat_len - j);
            }
            indexes.add(index + pat_len - 1);
            // indexes.add(index + pat_len - 2);
          }
        }
        // if(i < n - 1 && text.get(i+1) == pattern.get(0)) {
        //   curr_state = table[curr_state][pattern.get(0)];
        // } else {
        // }
      }
    }

    if(indexes.size() > 0) {
      for(int index : indexes) {
        System.out.print(index + " ");
      }
    } else {
      System.out.println("Nie znaleziono patternu");
    }
  }
}
