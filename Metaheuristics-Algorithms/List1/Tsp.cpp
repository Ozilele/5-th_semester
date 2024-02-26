#include <iostream>
#include <random>
#include <fstream>
#include <sstream>
#include <thread>
#include <vector>
#include <cmath>
#include <chrono>

#include "graph.hpp"
#include "local_search.hpp"

void testModifiedRandomLocalSearch(Tsp &tspSolver, std::vector<short> &cycle, int n) {
  std::cout << "Liczba iteracji algorytmu to " << n << std::endl;
  std::vector<std::thread> threads;
  for(int k = 0; k < n; k++) { // n permutations
    threads.push_back(std::thread([&tspSolver, &cycle]() {
      tspSolver.runModifiedLocalSearchRandom(cycle);
    }));
  }
  for(auto& thread : threads) {
    thread.join();
  }
  double avgScore = (double)tspSolver.weightSum / n;
  double avgSteps = (double)tspSolver.stepsSum / n;
  std::cout << "Średnia wartość uzyskanego rozwiązania to " << avgScore << std::endl;
  std::cout << "Średnia liczba kroków poprawy to " << avgSteps << std::endl;
  std::cout << "Najlepsze uzyskane rozwiązanie to " << tspSolver.lowestCost << std::endl;
}

void testRandomLocalSearch(Tsp &tspSolver, std::vector<short> &cycle, int n) {
  std::cout << "Liczba iteracji algorytmu to " << n << std::endl;
  std::vector<std::thread> threads;
  for(int k = 0; k < n; k++) {
    threads.push_back(std::thread([&tspSolver, &cycle]() {
      tspSolver.runLocalSearchRandom(cycle);
    }));
  }
  for(auto& thread : threads) {
    thread.join();
  }
  double avgScore = (double)tspSolver.weightSum / n;
  double avgSteps = (double)tspSolver.stepsSum / n;
  std::cout << "Średnia wartość uzyskanego rozwiązania to " << avgScore << std::endl;
  std::cout << "Średnia liczba kroków poprawy to " << avgSteps << std::endl;
  std::cout << "Najlepsze uzyskane rozwiązanie to " << tspSolver.lowestCost << std::endl;
}

void testLocalSearchMST(Tsp &tspSolver, std::vector<Edge> mstEdges, int size) {
  std::cout << "Liczba iteracji algorytmu to " << size << std::endl;
  std::vector<std::thread> threads;
  for(int i = 0; i < size; i++) {
    threads.push_back(std::thread([&tspSolver, &mstEdges]() {
      tspSolver.runLocalSearchMST(mstEdges);
    }));
  }
  for(auto& thread : threads) {
    thread.join();
  }
  double avgScore = (double)tspSolver.weightSum / size;
  double avgSteps = (double)tspSolver.stepsSum / size;
  std::cout << "Średnia wartość uzyskanego rozwiązania to " << avgScore << std::endl;
  std::cout << "Średnia liczba kroków poprawy to " << avgSteps << std::endl;
  std::cout << "Najlepsze uzyskane rozwiązanie to " << tspSolver.lowestCost << std::endl;
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
  Tsp *tspSolver = new Tsp();

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
  tspSolver->vertices = vertices;
  std::vector<Edge> edges;
  std::vector<Edge> mstEdges;
  std::vector<std::vector<int>> distances(n, std::vector<int>(n, 0));
  int edgesCount = 0;

  for(int i = 0; i < n - 1; i++) {
    for(int j = i + 1; j < n; j++) {
      int weight = tspSolver->calcDistance(vertices[i].x, vertices[i].y, vertices[j].x, vertices[j].y);
      distances[i][j] = weight;
      distances[j][i] = weight;
      Edge edge(vertices[i], vertices[j], weight);
      edges.push_back(edge);
      edgesCount++;
    }
  }
  tspSolver->edges = edges;
  tspSolver->distances = distances;

  std::sort(edges.begin(), edges.end(), EdgeComparator());
  mstEdges = minimumSpammingTree(n, edges, tspSolver);
  std::random_device rd;
  std::mt19937 gen(rd());
  int size = std::ceil(std::sqrt(n));
  int counter = 0;

  testLocalSearchMST(*tspSolver, mstEdges, size);
  // testRandomLocalSearch(*tspSolver, cycle, n);
  // testModifiedRandomLocalSearch(*tspSolver, cycle, n);

  // for(Node node : tspSolver->theBestCycle) {
  //   std::cout << "(" << node.x << "," << node.y << ")" << "," << " " << std::endl;
  // }
  auto end_time = std::chrono::high_resolution_clock::now();
  auto duration = std::chrono::duration_cast<std::chrono::microseconds>(end_time - start_time);
  std::cout << "Czas wykonania programu: " << (duration.count()) / 1000000  << " sekund." << std::endl;
  return 0;
}