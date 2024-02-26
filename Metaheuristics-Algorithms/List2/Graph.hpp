#pragma once
#ifndef GRAPH_HPP
#define GRAPH_HPP

#include <iostream>
#include <vector>
#include <random>
#include <cmath>
#include <functional>
#include <atomic>

class Node {
  public:
    int x;
    int y;
    int number;
    bool operator==(const Node& other) const {
      return (x == other.x && y == other.y && number == other.number);
    }
};

class Pair {
  public: 
    std::vector<Node> cycle;
    int weight;
    Pair(const std::vector<Node> cycle, int weight): cycle(cycle), weight(weight) { }
};

class Edge {
  public:
    Node src;
    Node dest;
    int weight;
    Edge() : src(Node()), dest(Node()), weight(0) {}
    Edge(const Node& src, const Node& dest, int weight): src(src), dest(dest), weight(weight) {}

    bool connects(const Node& node) {
      return (src == node || dest == node);
    }
    Node getNode(const Node& node) {
      if(src == node) {
        return dest;
      } else {
        return src;
      }
    }
};

struct EdgeComparator {
  bool operator()(const Edge& edge1, const Edge& edge2) const {
    return edge1.weight < edge2.weight;
  }
};

class Subset {
  public:
    int parent, rank;
    Subset() : parent(0), rank(0) {}
    Subset(int parent, int rank) : parent(parent), rank(rank) { }
};

class Graph {
  public:
    std::vector<Node> vertices;
    std::vector<std::vector<int>> distances;
    std::vector<std::vector<Edge>> adj;
    int lowestCost = INT_MAX;
    int weightSum = 0;

    std::vector<short> tspCycleDfs(std::vector<Edge>& edges, Node& currentNode, Node& startingNode, std::vector<bool>& visitedNodes, std::vector<short>& tspCycle, int numNodes) {
      visitedNodes[currentNode.number] = true;
      if(std::all_of(visitedNodes.begin(), visitedNodes.end(), [](bool visited) { return visited; }) && currentNode == startingNode) {
        // All vertices visited(hamiltonian cycle and back to starting vertice)
        return tspCycle;
      }
      for(const Edge& edge : this->adj[currentNode.number]) {
        Node nextNode = (currentNode.number == edge.src.number) ? edge.dest : edge.src;
        tspCycle.push_back(nextNode.number);

        if(!visitedNodes[nextNode.number]) {
          tspCycleDfs(edges, nextNode, startingNode, visitedNodes, tspCycle, numNodes);
        }
      }
      return tspCycle;
    }

    std::vector<short> createTspCycle(std::vector<Edge>& edges, Node& startingNode) {
      std::vector<short> tspCycle;
      tspCycle.push_back(startingNode.number);
      int nodesNum = edges.size() + 1;
      std::vector<bool> visitedNodes(nodesNum, false);
      tspCycleDfs(edges, startingNode, startingNode, visitedNodes, tspCycle, nodesNum);
      return tspCycle;
    }

    std::vector<short> invert(std::vector<short> &cycle, int i, int j) {
      std::vector<short> invertedList = cycle;
      while(i < j) {
        std::swap(invertedList[i], invertedList[j]);
        i++;
        j--;
      }
      return invertedList;
    }

    int calculateTSPCycleWeight(std::vector<short> &tspCycle) {
      int tspCycleWeight = 0;
      int n = tspCycle.size();
      for(int i = 0; i < n; i++) {
        short fromIndex = tspCycle[i];
        short toIndex = tspCycle[(i + 1) % n];
        tspCycleWeight += this->distances[fromIndex][toIndex];
      }
      return tspCycleWeight;
    }

    int calcDistance(int x1, int y1, int x2, int y2) {
      double distance = std::sqrt(std::pow(x1 - x2, 2) + std::pow(y1 - y2, 2));
      int roundedDistance = static_cast<int>(distance + 0.5);
      return roundedDistance;
    }

    unsigned int evaluateSolution(std::vector<short> &cycle, int i, int j, int weight) {
      unsigned int cost = weight;
      int n = cycle.size();
      if(i != 0 || j != n - 1) {
        short beforeI = cycle[(i - 1 + n) % n];
        short nodeI = cycle[i % n];
        short nodeJ = cycle[j % n];
        short nextJ = cycle[(j + 1) % n];
        cost -= this->distances[beforeI][nodeI];
        cost -= this->distances[nodeJ][nextJ];
        cost += this->distances[beforeI][nodeJ];
        cost += this->distances[nodeI][nextJ];
      }
      return cost;
    }
};

class SimulatedAnnealing {
  public:
    std::atomic<int> weightSum;
    int minCost = INT_MAX;
    double temp, alpha, epochs, stopIteration;
    SimulatedAnnealing(double temp, double alpha, double epochs, double stopIteration) : temp(temp), alpha(alpha), epochs(epochs), stopIteration(stopIteration) {}
      
    void runAlgorithm(std::vector<short> *cycle, Graph &graph, int weight) {
      int n = (*cycle).size();
      int maxIterations = int(n * stopIteration);
      double temperature = static_cast<double>(weight * temp);
      int maxEpochSize = int(n * epochs);
      int iterationWithoutImpr = 0;
      // std::cout << "N: " << n << ", " << "MaxIterations: " << maxIterations << ", " << "Temperature: " << temperature << ", " << "MaxEpoch: " << maxEpochSize << ", " << "Temp_alpha: " << alpha << std::endl;
      int currentWeight = weight;
      std::vector<short> currCycle = *cycle;
    
      std::vector<std::pair<short, short>> inversions;
      for(int i = 0; i < n - 1; i++) {
        for(int j = i + 1; j < n; j++) {
          inversions.emplace_back(i, j);
        }
      }
      std::mt19937 gen{std::random_device{}()};
      std::uniform_int_distribution<size_t> intDist(0, inversions.size() - 1);

      while(iterationWithoutImpr < maxIterations) {
        iterationWithoutImpr++;
        int currIteration = 0;

        while(currIteration < maxEpochSize) { // liczba prob przeprowadzonych w ramach jednej epoki z ta sama temperatura
          const auto neighbour = inversions[intDist(gen)];
          auto indexI = neighbour.first;
          auto indexJ = neighbour.second;

          if(indexI == 0 || indexJ == n - 1) {
            continue; // break iteration of while
          }
          unsigned int change = 0;
          change = graph.evaluateSolution(currCycle, indexI, indexJ, currentWeight);
          
          if(change < currentWeight) { // better solution
            currCycle = graph.invert(currCycle, indexI, indexJ);
            currentWeight = change;
            currIteration++;
            iterationWithoutImpr = 0;
          } else {
            std::uniform_real_distribution<double> realDist(0.0, 1.0);
            int difference = change - currentWeight;
            if(realDist(gen) < std::exp(-difference / temperature)) { // case when worse solution is taken
              currCycle = graph.invert(currCycle, indexI, indexJ);
              currIteration++;
              currentWeight = change;
            }
          }
        }
        temperature *= alpha;
      }

      if(currentWeight < minCost) {
        minCost = currentWeight;
      }

      weightSum += currentWeight; 
      *cycle = currCycle;
    }
};

#endif