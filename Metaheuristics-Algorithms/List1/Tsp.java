import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.security.SecureRandom;
import java.util.Comparator;
import java.util.LinkedHashSet;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Random;
import java.util.Set;

class Node {
  int x;
  int y;
  int number;
}

class Pair {
  List<Node> cycle;
  int weight;

  public Pair(List<Node> cycle, int weight) {
    this.cycle = cycle;
    this.weight = weight;
  }
}

class Edge {
  Node src;
  Node dest;
  int weight;
  public Edge(Node src, Node dest, int weight) {
    this.src = src;
    this.dest = dest;
    this.weight = weight;
  }
  public boolean connects(Node node) {
    return (src == node || dest == node);
  }
  public Node getNode(Node node) {
    if(src == node) {
      return dest;
    } else {
      return src;
    }
  }
}

class Subset {
  int parent, rank;
  public Subset(int parent, int rank) {
    this.parent = parent;
    this.rank = rank;
  }
}

public class Tsp {

  static int distances[][];
  static List<String> fileContent = new ArrayList<>();
  static Node[] vertices;
  static List<List<Edge>> adj;
  static Edge[] edges;
  static int steps = 0;
  static SecureRandom rand;
  static int lowestCost = Integer.MAX_VALUE;
  static int weightSum = 0;
  static int stepsSum = 0;
  static List<Node> theBestCycle;
  // cykle Hamiltona w problemie komiwojazera nazywamy rozwiązaniami, zaś minimalny cykl Hamiltona nazywamy rozwiązaniem optymalnym(optimum)
  // n(n - 1) / 2 because for each of n vertices pick n-1 edges and edges are counted twice so / 2
  public static void main(String[] args) {
    long begin = System.currentTimeMillis();
    String pathToFile = args[0];
    try {
      BufferedReader reader = new BufferedReader(new FileReader(pathToFile));
      String line;
      while((line = reader.readLine()) != null) {
        fileContent.add(line);
      }
      reader.close();
    } catch(IOException ex) {
      ex.printStackTrace();
    } 

    for(int i = 0; i < 8; i++) {
      fileContent.remove(0);
    }
    fileContent.remove(fileContent.size() - 1);
    vertices = new Node[fileContent.size()];

    for(int i = 0; i < fileContent.size(); i++) {
      String dataLine = fileContent.get(i);
      String[] data = dataLine.split(" ");
      Node newNode = new Node();
      newNode.x = Integer.parseInt(data[1]);
      newNode.y = Integer.parseInt(data[2]);
      newNode.number = i;
      vertices[i] = newNode;
    }
    int n = vertices.length;

    edges = new Edge[(n * (n-1)) / 2];
    distances = new int[n][n];
    int edgesCount = 0;

    for(int i = 0; i < n - 1; i++) {
      for(int j = i + 1; j < n; j++) {
        int weight = calcDistance(vertices[i].x, vertices[i].y, vertices[j].x, vertices[j].y);
        distances[i][j] = weight;
        distances[j][i] = weight;
        Edge edge = new Edge(vertices[i], vertices[j], weight);
        edges[edgesCount] = edge;
        edgesCount++;
      }
    }

    // calcPermutation(20, 50, vertices);
    Comparator<Edge> edgeComparator = (edge1, edge2) -> Integer.compare(edge1.weight, edge2.weight);
    Arrays.sort(edges, edgeComparator);
  
    Edge[] mstEdges = minimumSpammingTree(n, edges);
    System.out.println("MST EDGES size to " + mstEdges.length);
    // Tworzenie cyklu komiwojazera na podstawie MST i pierwszego wierzchołka
    rand = new SecureRandom();

    // int size = (int)Math.ceil(Math.sqrt(n));
    // System.out.println("Liczba iteracji to " + size);
    // Thread[] threads = new Thread[size];
    calcPermutation(0, 0, vertices);
    // for(int i = 0; i < size; i++) {
    //   threads[i] = new Thread(() -> runAlgorithm(mstEdges));
    //   threads[i].start();
    // }

    // for(int i = 0; i < size; i++) {
    //   try {
    //     threads[i].join();
    //   } catch(InterruptedException ex) {
    //     ex.printStackTrace();
    //   }
    // }
    // for(int i = 0; i < size; i++) {
    //   runAlgorithm(mstEdges);
    // }

    double avgScore = weightSum / vertices.length;
    double avgSteps = stepsSum / vertices.length;
    System.out.println("Średnia wartość uzyskanego rozwiązania to " + avgScore);
    System.out.println("Średnia liczba kroków poprawy to " + avgSteps);
    System.out.println("Najlepsze uzyskane rozwiązanie to " + lowestCost);

    // for(Node node : theBestCycle) {
    //   System.out.print("(" + node.x + "," + node.y + ")" + "," + " ");
    // }

    long end = System.currentTimeMillis();
    double time = (end - begin) / 1000;
    System.out.println("Elapsed Time: " + time + "seconds");
  }

  public static void runAlgorithm(Edge[] mstEdges) {
    int randomNr = rand.nextInt(mstEdges.length + 1); // 0 to n-1
    Node vertice = vertices[randomNr]; // wylosowany wierzchołek
    List<Node> tspCycle = createTSPCycle(mstEdges, vertice);
    Set<Node> uniqueSet = new LinkedHashSet<>(tspCycle);
    List<Node> uniqueCycle = new ArrayList<>(uniqueSet);
    // List<Node> uniqueCycle = new ArrayList<>();
    // for(Node node : tspCycle) {
    //   if(!uniqueCycle.contains(node)) {
    //     uniqueCycle.add(node);
    //   }
    // }
    uniqueCycle.add(vertice);
    System.out.println("Unique Cycle size to " + uniqueCycle.size());

    Pair data = localSearch(uniqueCycle); 
    // stepsSum += steps;
    // steps = 0;
    // weightSum += data.weight;
    // if(data.weight < lowestCost) {
    //   lowestCost = data.weight;
    //   theBestCycle = data.cycle;
    // }
    synchronized(Tsp.class) {
      stepsSum += steps;
      steps = 0;
      weightSum += data.weight;
      if(data.weight < lowestCost) {
        lowestCost = data.weight;
        theBestCycle = data.cycle;
      }
    }
  }

  public static int calcDistance(int x1, int y1, int x2, int y2) {
    double distance = Math.sqrt(Math.pow(x1 - x2, 2) + Math.pow(y1 - y2, 2));
    int roundedDistance = (int)(distance + 0.5);
    return roundedDistance;
  }

  public static int calculateTSPCycleWeight(List<Node> tspCycle) {
    int tspCycleWeight = 0;
    int n = tspCycle.size();

    for(int i = 0; i < n; i++) {
      Node from = tspCycle.get(i);
      Node to = tspCycle.get((i + 1) % n);
      tspCycleWeight += calcDistance(from.x, from.y, to.x, to.y);
    }
    return tspCycleWeight;
  }

  // O(j - i)
  public static List<Node> invert(List<Node> cycle, int i, int j) {
    List<Node> invertedList = new ArrayList<>(cycle.subList(0, i));
    for(int k = j; k >= i; k--) {
      invertedList.add(cycle.get(k));
    }
    invertedList.addAll(cycle.subList(j + 1, cycle.size()));
    return invertedList;
  }

  public static Pair localSearch(List<Node> cycle) {
    int n = cycle.size();
    List<Node> currentSolution = new ArrayList<>(cycle);
    List<Node> tmp;
    List<Node> betterSolution = new ArrayList<>();

    int min = calculateTSPCycleWeight(currentSolution);
    int currCost = min;
    boolean improvement = true;
    int maxiterations = 0;

    while(improvement) {
      improvement = false;

      for(int i = 0; i < n; i++) {
        for(int j = i + 1; j < n; j++) {
          tmp = invert(currentSolution, i, j);
          int newSolution = evaluateSolution(tmp, i, j, currCost, n);

          if(newSolution < min) { // Nowe rozwiązanie jest lepsze(mniejsza waga)
            improvement = true;
            betterSolution = tmp;
            min = newSolution;
          }
        }
      }

      if(improvement) {
        steps++;
        currentSolution = betterSolution;
        currCost = min;
      }
      maxiterations++;
    }
    return new Pair(currentSolution, min);
  }

  // Funkcja oceny
  public static int evaluateSolution(List<Node> cycle, int i, int j, int currCost, int n) {
    int cost = currCost;
    if(i != 0 || j != n - 1) {
      Node beforeI = cycle.get((i - 1 + n) % n);
      Node nodeI = cycle.get(i % n);
      Node nodeJ = cycle.get(j % n);
      Node nextJ = cycle.get((j + 1) % n);
      cost += distances[beforeI.number][nodeI.number];
      cost -= distances[beforeI.number][nodeJ.number];
      cost += distances[nodeJ.number][nextJ.number];
      cost -= distances[nodeI.number][nextJ.number];
    }
    return cost;
  }


  public static Pair modifiedLocalSearch(List<Node> permutation, int n) {
    int currentWeight = calculateTSPCycleWeight(permutation);
    int numVertices = permutation.size();

    boolean improved = true;
    while(improved) {
      improved = false;
      // Losowo wybieramy n sąsiadów
      List<List<Node>> neighbors = generateRandomNeighbors(permutation, n);

      for(List<Node> neighbor : neighbors) {
        int neighborWeight = calculateTSPCycleWeight(neighbor);
        steps++;

        if(neighborWeight < currentWeight) {
          permutation = neighbor;
          currentWeight = neighborWeight;
          improved = true;
          // break; // Przerywamy pętlę po znalezieniu lepszego sąsiada
        }
      }
    }
    return new Pair(permutation, currentWeight);
  }

  public static void calcPermutation(int numGroups, int groupSize, Node[] vertices) {
    // vertices 
    Random random = new Random();
    List<Integer> minimumValues = new ArrayList<>();
    List<List<Node>> perms = new ArrayList<>();
    double min = Integer.MAX_VALUE;
    int n = vertices.length;

    for(int i = 0; i < n; i++) {
      List<Node> perm = new ArrayList<>(Arrays.asList(vertices)); // tworzenie kopii oryginalnej listy vertices
      Collections.shuffle(perm, random); // permutowanie listy wierzchołków
      // List<List<Node>> neighbors = generateRandomNeighbors(perm, n);
      // Pair data = localSearch(perm); 
      Pair data = modifiedLocalSearch(perm, n);
      stepsSum += steps;
      steps = 0;
      // weightSum += data.weight;
      weightSum += data.weight;

      if(data.weight < min) {
        min = data.weight;
        theBestCycle = data.cycle;
      }
      // if(data.weight < lowestCost) {
      //   lowestCost = data.weight;
      //   theBestCycle = data.cycle;
      // }
    }
  }

  public static List<List<Node>> generateRandomNeighbors(List<Node> perm, int n) {
    Random random = new Random();
    List<List<Node>> neighbors = new ArrayList<>();
    for(int i = 0; i < n; i++) {
      List<Node> neighbor = new ArrayList<>(perm);
      int swapIndex1 = random.nextInt(neighbor.size());
      int swapIndex2 = random.nextInt(neighbor.size());

      // Swap two elements to create a neighbor
      Node temp = neighbor.get(swapIndex1);
      neighbor.set(swapIndex1, neighbor.get(swapIndex2));
      neighbor.set(swapIndex2, temp);

      neighbors.add(neighbor);
    }
    return neighbors;
  }
  
  // Liczba wierzchołków jak w grafie, liczba krawędzi to n-1, gdzie n to liczba wierzchołków
  // Totalny koszt(waga) drzewa jest zdefiniowana jako suma wag krawędzi wszystkich krawędzi drzewa
  // Kruskal's Minimum Spanning Tree Algorithm
  public static Edge[] minimumSpammingTree(int n, Edge[] edges) {
    // Iteracje w celu znalezienia minimalnego drzewa, w kazdej z nich algorytm dodaje nastepna najmniejsza wagowo krawedz aby te krawedzi nie tworzyły cyklu 
    int j = 0;
    int edgesCount = 0;

    Subset[] subsets = new Subset[n];
    Edge[] mstEdges = new Edge[n - 1];

    adj = new ArrayList<>(n);
    for(int i = 0; i < n; i++) {
      adj.add(new ArrayList<>());
    }

    // Pojedyncze podzbiory 
    for(int i = 0; i < n; i++) {
      subsets[i] = new Subset(i, 0);
    }

    while(edgesCount < n - 1) {
      Edge edge = edges[j];
      int x = findRoot(subsets, edge.src.number);
      int y = findRoot(subsets, edge.dest.number);

      // If this is applied, this edge does not cause a cycle
      if(x != y) {
        mstEdges[edgesCount] = edge;
        adj.get(edge.src.number).add(edge); // adj[1] -> Edge[1, 2, 1] 
        adj.get(edge.dest.number).add(edge);
        // System.out.println("The edge is " + edge.src.number + " " + edge.dest.number);
        union(subsets, x, y);
        edgesCount++;
      }
      j++;
    }

    int minCost = 0;
    for(int i = 0; i < edgesCount; i++) {
      // System.out.println("(" + mstEdges[i].src.x + "," + mstEdges[i].src.y + "), (" + mstEdges[i].dest.x + "," + mstEdges[i].dest.y + "),");
      minCost += mstEdges[i].weight;
    }
    System.out.println("Waga minimalnego drzewa rozpinającego to: " + minCost);
    return mstEdges;
  }

  // Merge rozłącznego zbioru z pojedynczym rozłącznym zbiorem, unite 2 disjoint sets
  public static void union(Subset[] subsets, int x, int y) {
    int rootX = findRoot(subsets, x);
    int rootY = findRoot(subsets, y);

    if(subsets[rootY].rank < subsets[rootX].rank) {
      subsets[rootY].parent = rootX;
    } else if(subsets[rootX].rank < subsets[rootY].rank) {
      subsets[rootX].parent = rootY;
    } else {
      subsets[rootY].parent = rootX;
      subsets[rootX].rank++;
    }
  }

  // Function for finding parent of a set
  private static int findRoot(Subset[] subsets, int i) {
    // i-ty element subsets jest rodzicem i elementu
    if(subsets[i].parent == i) {
      return subsets[i].parent;
    }
    subsets[i].parent = findRoot(subsets, subsets[i].parent);
    return subsets[i].parent;
  }

  public static List<Node> tspCycleDfs(Edge[] edges, Node currentNode, Node startingNode, List<Node> visitedNodes, List<Node> tspCycle, int numNodes) {
    visitedNodes.add(currentNode); // checking the visited status
    if(visitedNodes.size() == numNodes && currentNode == startingNode) {
      // Wszystkie wierzchołki odwiedzone (cykl komiwojażera) i powrót do wierzchołka początkowego
      return tspCycle;
    }
    // adj.get(currentNode.number)
    for(Edge edge : adj.get(currentNode.number)) {
      Node nextNode;
      if(currentNode.number == edge.src.number) {
        nextNode = edge.dest;
      } else {
        nextNode = edge.src;
      }
      tspCycle.add(nextNode);
      if(!visitedNodes.contains(nextNode)) { // eksploracja wierzchołka
        tspCycleDfs(edges, nextNode, startingNode, visitedNodes, tspCycle, numNodes);
      }
    }
    return tspCycle;
  }

  public static List<Node> createTSPCycle(Edge[] edges, Node startingNode) {
    List<Node> tspCycle = new ArrayList<>();
    tspCycle.add(startingNode);
    List<Node> visitedNodes = new ArrayList<>();
    int nodesNum = edges.length + 1;

    tspCycleDfs(edges, startingNode, startingNode, visitedNodes, tspCycle, nodesNum);
    return tspCycle;
  }
  
}


