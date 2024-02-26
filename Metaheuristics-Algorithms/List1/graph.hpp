#pragma once
#ifndef GRAPH_HPP
#define GRAPH_HPP

#include <iostream>
#include <vector>
#include <random>
#include <unordered_set>
#include <functional>

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
    std::vector<short> cycle;
    int weight;
    Pair(const std::vector<short> cycle, int weight): cycle(cycle), weight(weight) { }
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

class Tsp {

  public:
    std::vector<std::vector<int>> distances;
    std::vector<Node> vertices;
    std::vector<std::vector<Edge>> adj;
    std::vector<Edge> edges;
    std::mt19937 gen;
    int steps = 0;
    int lowestCost = INT_MAX;
    int weightSum = 0;
    int stepsSum = 0;
    std::vector<short> theBestCycle;
    Tsp() : gen(std::random_device()()) {}

    int calcDistance(int x1, int y1, int x2, int y2) {
      double distance = std::sqrt(std::pow(x1 - x2, 2) + std::pow(y1 - y2, 2));
      int roundedDistance = static_cast<int>(distance + 0.5);
      return roundedDistance;
    }

    int calculateTSPCycleWeight(std::vector<short> &tspCycle) {
      int tspCycleWeight = 0;
      int n = tspCycle.size();
      for(int i = 0; i < n; i++) {
        short from = tspCycle[i];
        short to = tspCycle[(i + 1) % n];
        tspCycleWeight += this->distances[from][to];
      }
      return tspCycleWeight;
    }

    int generateRandom(int size) {
      std::uniform_int_distribution<size_t> distribution(0, size - 1);
      return distribution(this->gen);
    }

    std::vector<short> tspCycleDfs(std::vector<Edge>& edges, Node& currentNode, Node& startingNode, std::vector<bool>& visitedNodes, std::vector<short>& tspCycle, int numNodes) {
      visitedNodes[currentNode.number] = true;
      if(std::all_of(visitedNodes.begin(), visitedNodes.end(), [](bool visited) { return visited; }) && currentNode == startingNode) {
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

    unsigned int evaluateSolution(std::vector<short> &cycle, int i, int j, int currCost, int n) {
      int cost = currCost;
      if(i != 0 || j != n - 1) {
        short beforeI = cycle[(i - 1 + n) % n];
        short nodeI = cycle[i % n];
        short nodeJ = cycle[j % n];
        short nextJ = cycle[(j + 1) % n];
        cost += this->distances[beforeI][nodeI];
        cost += this->distances[nodeJ][nextJ];
        cost -= this->distances[beforeI][nodeJ];
        cost -= this->distances[nodeI][nextJ];
      }
      return cost;
    }

    Pair localSearch(std::vector<short> &cycle) {
      int n = cycle.size();
      std::vector<short> currentSolution(cycle);
      std::vector<short> tmp;
      std::vector<short> betterSolution;
      int min = calculateTSPCycleWeight(currentSolution);
      int currCost = min;
      bool improvement = true;
      int maxiterations = 0;

      while(improvement) {
        improvement = false;
        for(int i = 0; i < n; i++) {
          for(int j = i + 1; j < n; j++) {
            tmp = invert(currentSolution, i, j);
            int newSolution = evaluateSolution(tmp, i, j, currCost, n);
            if(newSolution < min) {
              min = newSolution;
              improvement = true;
              betterSolution = tmp;
            }
          }
        }
        if(improvement) {
          this->steps++;
          currentSolution = betterSolution;
          currCost = min;
        }
        maxiterations++;
      }
      return Pair(currentSolution, currCost);
    }

    Pair modifiedLocalSearch(std::vector<short> &cycle) {
      int n = cycle.size();
      std::vector<short> currentSolution(cycle);
      std::vector<short> tmp;
      std::vector<short> betterSolution;
      std::vector<std::pair<short, short>> inversions;
      int min = calculateTSPCycleWeight(currentSolution);
      int currCost = min;
      bool improvement = true;
      int maxiterations = 0;
      for(int i = 0; i < n - 1; i++) {
        for(int j = i + 1; j < n; j++) {
          inversions.emplace_back(i, j);
        }
      }

      while(improvement) {
        improvement = false;
        for(int i = 0; i < n; i++) { // n trials with random neighbor
          const auto neighbor = inversions[generateRandom(inversions.size())];
          short indexI = neighbor.first;
          short indexJ = neighbor.second;
          if(indexI == 0 || indexJ == n - 1) {
            continue;
          }
          tmp = invert(currentSolution, indexI, indexJ);
          unsigned int newSolution = evaluateSolution(tmp, indexI, indexJ, currCost, n);
          if(newSolution < min) {
            min = newSolution;
            improvement = true;
            betterSolution = tmp;
          }
        }
        if(improvement) {
          this->steps++;
          currentSolution = betterSolution;
          currCost = min;
        }
        maxiterations++;
      }
      return Pair(currentSolution, currCost);
    }

    void runLocalSearchMST(std::vector<Edge> &mstEdges) {
      int randomNum = this->generateRandom(mstEdges.size() + 1);
      Node vertice = this->vertices[randomNum];
      std::vector<short> tspCycle = createTspCycle(mstEdges, vertice);
      for(unsigned int i = 1; i < tspCycle.size(); ++i) {
        for (unsigned int k = 0 ; k < i; ++k) {
          if(tspCycle.at(i) == tspCycle.at(k)) {
            tspCycle.erase(tspCycle.begin() + i);
            --i;
            break;
          }
        }
      }
      tspCycle.push_back(vertice.number);
      Pair data = localSearch(tspCycle);
      this->stepsSum += this->steps;
      this->steps = 0;
      this->weightSum += data.weight;
      if(data.weight < this->lowestCost) {
        this->lowestCost = data.weight;
        this->theBestCycle = data.cycle;
      }
    }

    void runLocalSearchRandom(std::vector<short> &cycle) {
      std::vector<short> tmpCycle = cycle;
      std::shuffle(tmpCycle.begin(), tmpCycle.end(), this->gen);
      tmpCycle.push_back(tmpCycle[0]);   
      Pair data = localSearch(tmpCycle);
      this->stepsSum += this->steps;
      this->steps = 0;
      this->weightSum += data.weight;
      if(data.weight < this->lowestCost) {
        this->lowestCost = data.weight;
        this->theBestCycle = data.cycle;
      }
    }

    void runModifiedLocalSearchRandom(std::vector<short> &cycle) {
      std::vector<short> tmpCycle = cycle;
      std::shuffle(tmpCycle.begin(), tmpCycle.end(), this->gen);
      tmpCycle.push_back(tmpCycle[0]);   
      Pair data = modifiedLocalSearch(tmpCycle);
      this->stepsSum += this->steps;
      this->steps = 0;
      this->weightSum += data.weight;
      if(data.weight < this->lowestCost) {
        this->lowestCost = data.weight;
        this->theBestCycle = data.cycle;
      }
    }
};

#endif
