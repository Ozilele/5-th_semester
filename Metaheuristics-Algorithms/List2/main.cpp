#include <iostream>
#include <random>
#include <vector>
#include <sstream>
#include <fstream>
#include <algorithm>
#include <thread>
#include <memory>
#include <unordered_set>
#include <chrono>

#include "Graph.hpp"
#include "Search.hpp"
#include "Tree.hpp"

struct NodeHash {
  size_t operator()(const Node& node) const {
    return std::hash<int>()(node.x) ^ std::hash<int>()(node.y);
  }
};

void runSaveData(int n, int maxIterations, std::vector<Node> &vertices, std::vector<Edge> &mstEdges, Graph &graph) {
  double tabuList = 0.05;
  std::random_device rd;
  std::uniform_int_distribution<int> intDist(0, vertices.size() - 1);
  std::mt19937 g(rd());
  std::ofstream MyFile("testing.txt");

  while(tabuList < 1) {
    int tabuListSize = static_cast<int>(tabuList * n);
    auto start = std::chrono::high_resolution_clock::now();
    TabuSearch *tabuSearch = new TabuSearch(tabuListSize, maxIterations);
    std::vector<std::thread> threads;

    for(int i = 0; i < 50; i++) {
      Node startingNode = vertices[intDist(g)];
      std::vector<short> tspCycle = graph.createTspCycle(mstEdges, startingNode);
      for(unsigned int i = 1; i < tspCycle.size(); ++i) {
        for(unsigned int k = 0 ; k < i; ++k) {
          if(tspCycle.at(i) == tspCycle.at(k)) {
            tspCycle.erase(tspCycle.begin() + i);
            --i;
            break;
          }
        }
      }
      tspCycle.push_back(startingNode.number);
      // std::vector<Node> tmpVertices = vertices;
      // std::shuffle(tmpVertices.begin(), tmpVertices.end(), g);
      // tmpVertices.push_back(tmpVertices[0]);

      threads.push_back(std::thread([&tabuSearch, &graph, tspCycle = std::move(tspCycle)]() mutable {
        // int tspCycleWeight = graph.calculateTSPCycleWeight(tspCycle);
        // tabuSearch->runRandomizedNeighborhoodAlgorithm(&tspCycle, graph, tspCycleWeight);
        // tabuSearch->runAlgorithm(&tspCycle, *graph, tspCycleWeight);
      }));
    }

    for(auto& thread : threads) {
      thread.join();
    }

    std::cout << tabuSearch->weightSum << std::endl;
    double avgWeight = (double)tabuSearch->weightSum / 50;
    int naj = tabuSearch->minCost;
    std::cout << "Średnia wartość uzyskanego rozwiązania to " << avgWeight << std::endl;
    std::cout << "Najlepsza wartosc uzyskanego rozwiązania to: " << naj << std::endl;

    MyFile << tabuList << " " << avgWeight << std::endl;
    tabuList += 0.1;
    delete tabuSearch;
  }
  MyFile.close();
}

void testSimulatedAnnealing(SimulatedAnnealing &simulatedAnnealing, std::vector<short> &cycle, Graph &graph, std::vector<Node> &vertices) {
  std::random_device rd;
  std::uniform_int_distribution<int> intDist(0, vertices.size() - 1);
  std::mt19937 g(rd());
  std::vector<std::thread> threads;
  int iterations = 100;
  for(int i = 0; i < iterations; i++) {
    std::vector<short> tmpCycle = cycle;
    std::shuffle(tmpCycle.begin(), tmpCycle.end(), g);
    tmpCycle.push_back(tmpCycle[0]);    

    threads.push_back(std::thread([&simulatedAnnealing, &graph, tmpCycle = std::move(tmpCycle)]() mutable {
      int tspCycleWeight = graph.calculateTSPCycleWeight(tmpCycle);
      simulatedAnnealing.runAlgorithm(&tmpCycle, graph, tspCycleWeight);
    }));
  }
  for(auto& thread : threads) {
    thread.join();
  }
  double avgWeight = (double)simulatedAnnealing.weightSum / iterations;
  std::cout << "Średnia wartość uzyskanego rozwiązania to " << avgWeight << std::endl;
  int lowest = simulatedAnnealing.minCost;
  std::cout << "Najlepsza wartosc uzyskanego rozwiązania to: " << lowest << std::endl;
}

void testTabuSearch(TabuSearch &tabuSearch, std::vector<short> &cycle, Graph &graph, std::vector<Node> &vertices, std::vector<Edge>& mstEdges, bool isMSTProvided) {
  std::random_device rd;
  std::uniform_int_distribution<int> intDist(0, vertices.size() - 1);
  std::mt19937 g(rd());
  std::vector<std::thread> threads;
  int iterations = 100; 

  for(int i = 0; i < iterations; i++) {
    std::vector<short> tmpCycle;
    if(isMSTProvided) { // beginning solution based on MST
      Node startingNode = vertices[intDist(g)];
      tmpCycle = graph.createTspCycle(mstEdges, startingNode);
      for(unsigned int i = 1; i < tmpCycle.size(); ++i) {
        for(unsigned int k = 0 ; k < i; ++k) {
          if(tmpCycle.at(i) == tmpCycle.at(k)) {
            tmpCycle.erase(tmpCycle.begin() + i);
            --i;
            break;
          }
        }
      }
      tmpCycle.push_back(startingNode.number);
    } else { // random beginning solution
      tmpCycle = cycle;
      std::shuffle(tmpCycle.begin(), tmpCycle.end(), g);
      tmpCycle.push_back(tmpCycle[0]);    
    }
    threads.push_back(std::thread([&tabuSearch, &graph, tmpCycle = std::move(tmpCycle)]() mutable {
      int tspCycleWeight = graph.calculateTSPCycleWeight(tmpCycle);
      // tabuSearch.runAlgorithm(&tmpCycle, graph, tspCycleWeight);
      tabuSearch.runRandomizedNeighborhoodAlgorithm(&tmpCycle, graph, tspCycleWeight);
    }));
  }
  for(auto& thread : threads) {
    thread.join();
  }
  double avgWeight = (double)tabuSearch.weightSum / iterations;
  std::cout << "Średnia wartość uzyskanego rozwiązania to " << avgWeight << std::endl;
  int lowest = tabuSearch.minCost;
  std::cout << "Najlepsza wartosc uzyskanego rozwiązania to: " << lowest << std::endl;
}

int main(int argc, char *argv[]) {
  auto start_time = std::chrono::high_resolution_clock::now();
  std::string pathToFile = argv[1];
  std::ifstream fileStream(pathToFile);

  if(!fileStream.is_open()) {
    std::cerr << "Unable to open file: " << pathToFile << std::endl;
    return 1;
  }
  std::vector<std::string> fileContent;
  std::string line;
  while(std::getline(fileStream, line)) {
    fileContent.push_back(line);
  }
  fileStream.close();

  for(int i = 0; i < 8; i++) {
    fileContent.erase(fileContent.begin());
  }
  fileContent.pop_back();

  std::vector<Node> vertices(fileContent.size());
  Graph *graph = new Graph();
  for(int i = 0; i < fileContent.size(); i++) {
    std::istringstream dataLineStream(fileContent[i]);
    std::string data;
    dataLineStream >> data;
    Node newNode;
    dataLineStream >> newNode.x >> newNode.y;
    newNode.number = i;
    vertices[i] = newNode;
  }

  std::vector<short> cycle;
  for(int j = 0; j < vertices.size(); j++) {
    cycle.push_back(vertices[j].number);
  }

  int n = vertices.size();
  std::vector<Edge> edges;
  std::vector<Edge> mstEdges;
  std::vector<std::vector<int>> distances(n, std::vector<int>(n, 0));
  int edgesCount = 0;

  for(int i = 0; i < n - 1; i++) {
    for(int j = i + 1; j < n; j++) {
      int weight = graph->calcDistance(vertices[i].x, vertices[i].y, vertices[j].x, vertices[j].y);
      distances[vertices[i].number][vertices[j].number] = weight;
      distances[vertices[j].number][vertices[i].number] = weight;
      Edge edge(vertices[i], vertices[j], weight);
      edges.push_back(edge);
      edgesCount++;
    }
  }
  graph->distances = distances;
  graph->vertices = vertices;

  std::sort(edges.begin(), edges.end(), EdgeComparator());
  mstEdges = minimumSpammingTree(n, edges, graph);

  int tabuListSize = static_cast<int>(0.1 * n);
  int maxIterations = static_cast<int>(0.2 * n);
  std::vector<std::vector<Node>> initialCycles;

  TabuSearch *tabuSearch = new TabuSearch(tabuListSize, maxIterations);
  // SimulatedAnnealing *simulatedAnnealing = new SimulatedAnnealing(0.5, 0.95, 0.2, 0.1);
  // testSimulatedAnnealing(*simulatedAnnealing, cycle, *graph, vertices);
  testTabuSearch(*tabuSearch, cycle, *graph, vertices, mstEdges, false);
  auto end_time = std::chrono::high_resolution_clock::now();
  auto duration = std::chrono::duration_cast<std::chrono::microseconds>(end_time - start_time);
  std::cout << "Czas wykonania programu: " << (duration.count()) / 1000000  << " sekund." << std::endl;
  return 0;
}