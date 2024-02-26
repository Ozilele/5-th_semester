#pragma once
#ifndef MST_TREE_HPP
#define MST_TREE_HPP

#include <cmath>
#include <vector>
#include "Graph.hpp"

// Function for finding parent of a set
int findRoot(std::vector<Subset>& subsets, int i) {
  if(subsets[i].parent == i) {
    return subsets[i].parent;
  }
  subsets[i].parent = findRoot(subsets, subsets[i].parent);
  return subsets[i].parent;
}

// Merge rozłącznego zbioru z pojedynczym rozłącznym zbiorem, unite 2 disjoint sets
void unionSets(std::vector<Subset>& subsets, int x, int y) {
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

std::vector<Edge> minimumSpammingTree(int n, std::vector<Edge> edges, Graph *graph) {
  int j = 0;
  int edgesCount = 0;
  std::vector<Subset> subsets(n);
  std::vector<Edge> mstEdges(n - 1);

  std::vector<std::vector<Edge>> adj(n);
  for(int i = 0; i < n; i++) {
    adj[i] = std::vector<Edge>();
  }

  for(int i = 0; i < n; i++) {
    subsets[i] = Subset(i, 0);
  }

  while(edgesCount < n - 1) {
    Edge edge = edges[j];
    int x = findRoot(subsets, edge.src.number);
    int y = findRoot(subsets, edge.dest.number);
    // If this is applied, this edge does not cause a cycle
    if(x != y) {
      mstEdges[edgesCount] = edge;
      adj[edge.src.number].push_back(edge);
      adj[edge.dest.number].push_back(edge);
      unionSets(subsets, x, y);
      edgesCount++;
    }
    j++;
  }
  int minCost = 0;
  for(int i = 0; i < edgesCount; i++) {
    minCost += mstEdges[i].weight;
  }
  graph->adj = adj;
  std::cout << "Waga minimalnego drzewa rozpinającego to: " << minCost << std::endl;
  return mstEdges;
}

#endif