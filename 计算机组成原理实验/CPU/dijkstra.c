#include <stdio.h>
#include <limits.h>
#include <stdlib.h>
#include <time.h>

#define V 10
#define INF INT_MAX

// 获取距离最短且未被访问的顶点
int minDistance(int dist[], int visited[]) {
    int min = INF, min_index;
    for (int v = 0; v < V; v++) {
        if (!visited[v] && dist[v] <= min) {
            min = dist[v];
            min_index = v;
        }
    }
    return min_index;
}

// 打印最短路径
void printPath(int parent[], int j) {
    if (parent[j] == -1) {
        return;
    }
    printPath(parent, parent[j]);
    printf(" -> %d", j);
}

// 打印结果
void printSolution(int dist[], int parent[], int start, int end) {
    printf("Vertex\t Distance\tPath\n");
    printf("%d -> %d \t %d\t\t%d", start, end, dist[end], start);
    printPath(parent, end);
    printf("\n");
}

// 打印图的邻接矩阵
void printGraph(int graph[V][V]) {
    printf("Graph adjacency matrix:\n");
    for (int i = 0; i < V; i++) {
        for (int j = 0; j < V; j++) {
            if (graph[i][j] == 0) {
                printf("   ");
            } else {
                printf("%2d ", graph[i][j]);
            }
        }
        printf("\n");
    }
}

// 迪杰斯特拉算法
void dijkstra(int graph[V][V], int start, int end) {
    int dist[V];//存储从起点到每个顶点的最短距离。初始时，起点的距离为 0，其他顶点的距离为无穷大（INF）。
    int visited[V];
    int parent[V];

    for (int i = 0; i < V; i++) {
        dist[i] = INF;
        visited[i] = 0;
        parent[i] = -1;
    }

    dist[start] = 0;

    for (int count = 0; count < V - 1; count++) {
        int u = minDistance(dist, visited);
        visited[u] = 1;

        for (int v = 0; v < V; v++) {
            if (!visited[v] && graph[u][v] && dist[u] != INF && dist[u] + graph[u][v] < dist[v]) {
                dist[v] = dist[u] + graph[u][v];
                parent[v] = u;
            }
        }
    }

    printSolution(dist, parent, start, end);
}

int main() {
    int graph[V][V];
    srand(time(0));

    // 生成随机图
    for (int i = 0; i < V; i++) {
        for (int j = 0; j < V; j++) {
            if (i == j) {
                graph[i][j] = 0;
            } else {
                graph[i][j] = rand() % 20 ; // 随机生成0到20之间的权重
            }
        }
    }

    int start, end;
    printf("Enter start point (0-9): ");
    scanf("%d", &start);
    printf("Enter end point (0-9): ");
    scanf("%d", &end);

    // 打印图的邻接矩阵
    printGraph(graph);

    dijkstra(graph, start, end);

    return 0;
}