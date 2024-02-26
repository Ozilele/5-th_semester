import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.Comparator;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Random;

class Node {
  int x;
  int y;
  int number;
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
  static List<String> fileContent = new ArrayList<>();
  static Node[] vertices;
  static List<List<Edge>> adj;
  static int totalWeightOfTSP = 0;
  // cykle Hamiltona w problemie komiwojazera nazywamy rozwiązaniami, zaś minimalny cykl Hamiltona nazywamy rozwiązaniem optymalnym(optimum)
  // n(n - 1) / 2 because for each of n vertices pick n-1 edges and edges are counted twice so / 2
  public static void main(String[] args) {
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
    Edge[] edges = new Edge[(n * (n-1)) / 2];
    int edgesCount = 0;
    for(int i = 0; i < n - 1; i++) {
      for(int j = i + 1; j < n; j++) {
        int weight = calcDistance(vertices[i].x, vertices[i].y, vertices[j].x, vertices[j].y);
        Edge edge = new Edge(vertices[i], vertices[j], weight);
        edges[edgesCount] = edge;
        edgesCount++;
      }
    }
    calcPermutation(20, 50, vertices);
    // Sorting all edges of the graph 
    Comparator<Edge> edgeComparator = (edge1, edge2) -> Integer.compare(edge1.weight, edge2.weight);
    Arrays.sort(edges, edgeComparator);
    Edge[] mstEdges = minimumSpammingTree(n, edges);
    // Creating tspCycle based on MST and first vertice
    List<Node> tspCycle = createTSPCycle(mstEdges, vertices[0]);
    System.out.println("Cykl komiwojażera:");
    List<Node> uniqueCycle = new ArrayList<>();
    for(Node node : tspCycle) {
      if(!uniqueCycle.contains(node)) {
        uniqueCycle.add(node);
      }
    }
    uniqueCycle.add(vertices[0]);
    for(Node node : uniqueCycle) {
      System.out.print("(" + node.x + "," + node.y + ")" + "," + " ");
    }
    int tspCycleWeight = calculateTSPCycleWeight(edges, uniqueCycle);
    System.out.println("\nWaga cyklu komiwojażera korzystając z MST: " + tspCycleWeight);
  }

  public static int calcDistance(int x1, int y1, int x2, int y2) {
    double distance = Math.sqrt(Math.pow(x1 - x2, 2) + Math.pow(y1 - y2, 2));
    int roundedDistance = (int) (distance + 0.5);
    return roundedDistance;
  }

  public static int calculateTSPCycleWeight(Edge[] edges, List<Node> tspCycle) {
    int tspCycleWeight = 0;
    for(int i = 0; i < tspCycle.size() - 1; i++) {
      Node from = tspCycle.get(i);
      Node to = tspCycle.get((i + 1) % tspCycle.size());
      for(Edge edge : edges) {
        if( (edge.src == from && edge.dest == to) || (edge.src == to && edge.dest == from) ) {
          tspCycleWeight += edge.weight;
          break;
        }
      }
    }
    return tspCycleWeight;
  }

  public static void calcPermutation(int numGroups, int groupSize, Node[] vertices) {
    // vertices 
    Random random = new Random();
    List<Integer> minimumValues = new ArrayList<>();
    List<List<Node>> perms = new ArrayList<>();
    double min = Integer.MAX_VALUE;
    // for(int i = 0; i < numPermutations; i++) {
    //   List<Node> perm = new ArrayList<>(Arrays.asList(vertices)); // tworzenie kopii oryginalnej listy vertices
    //   Collections.shuffle(perm, random); // permutowanie listy wierzchołków
    //   perms.add(perm);
    // }
    // for(List<Node> perm : perms) {
    //   int totalDistance = calculateWholeDistance(perm);
    //   if(totalDistance < min) {
    //     min = totalDistance;
    //   }
    // }
    // System.out.println("Minimum łączny dystans wśród 1000 permutacji: " + min);
    
    for(int group = 0; group < numGroups; group++) {
      int globalMIn = Integer.MAX_VALUE;
      for(int i = 0; i < groupSize; i++) {
        List<Node> randomPermutation = new ArrayList<>(Arrays.asList(vertices));
        Collections.shuffle(randomPermutation, random);
        perms.add(randomPermutation);
        int totalDist = calculateWholeDistance(randomPermutation);
        if(totalDist < globalMIn) {
          globalMIn = totalDist;
        }
      }
      minimumValues.add(globalMIn);
    }      

    int totalMin = 0;
    int global_min = Integer.MAX_VALUE;
    for(int minVal : minimumValues) {
      if(minVal < global_min) {
        global_min = minVal;
      }
      totalMin += minVal;
    }

    double averageMinimum = (double) totalMin / numGroups;
    System.out.println("Średnia z minimum: " + averageMinimum);
    System.out.println("Minimalna wartość dla losowań to " + global_min);
  }

  private static int calculateWholeDistance(List<Node> permutation) {
    int dist = 0;
    for(int i = 0; i < permutation.size() - 1; i++) {
      int weight = calcDistance(permutation.get(i).x, permutation.get(i).y, permutation.get(i + 1).x, permutation.get(i + 1).y);
      dist += weight;
    }
    return dist;
  }
  
  // Minimum Spamming Tree
  // The number of vertices the same as in the graph, the number of edges is n-1
  // Acycling, nie moze być rozłączone
  // All the cost(weight) of the tree is defined as sum of edges weights
  // Kruskal's Minimum Spanning Tree Algorithm
  public static Edge[] minimumSpammingTree(int n, Edge[] edges) {
    int j = 0;
    int edgesCount = 0;

    Subset[] subsets = new Subset[n];
    Edge[] mstEdges = new Edge[n - 1];

    adj = new ArrayList<>(n);
    for(int i = 0; i < n; i++) {
      adj.add(new ArrayList<>());
    }

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
        union(subsets, x, y);
        edgesCount++;
      }
      j++;
    }

    System.out.println("Following are the edges of the constructed MST:"); 
    int minCost = 0;
    for(int i = 0; i < edgesCount; i++) {
      System.out.println("(" + mstEdges[i].src.x + "," + mstEdges[i].src.y + "), (" + mstEdges[i].dest.x + "," + mstEdges[i].dest.y + "),");
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

    for(Edge edge : adj.get(currentNode.number)) {
      totalWeightOfTSP += edge.weight;
      Node nextNode;
      if(currentNode.number == edge.src.number) {
        nextNode = edge.dest;
      } else {
        nextNode = edge.src;
      }
      tspCycle.add(nextNode);
      if(!visitedNodes.contains(nextNode)) {
        tspCycleDfs(edges, nextNode, startingNode, visitedNodes, tspCycle, numNodes);
      }
    }
    return tspCycle;
  }

  public static List<Node> createTSPCycle(Edge[] edges, Node startingNode) {
    List<Node> tspCycle = new ArrayList<>();
    List<Node> visitedNodes = new ArrayList<>();
    int nodesNum = edges.length + 1;
    tspCycle.add(startingNode);
    tspCycleDfs(edges, startingNode, startingNode, visitedNodes, tspCycle, nodesNum);
    return tspCycle;
  }
}


