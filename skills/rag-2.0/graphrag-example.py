# GraphRAG Implementation
# Knowledge Graph + RAG for complex multi-hop queries

import networkx as nx
from typing import List, Dict, Any
from sentence_transformers import SentenceTransformer
import numpy as np

class GraphRAG:
    """
    GraphRAG: Combine Knowledge Graphs with RAG for better reasoning

    Use cases:
    - Multi-hop questions ("Who directed the movie starring X?")
    - Relationship queries ("How are X and Y connected?")
    - Complex reasoning requiring graph traversal
    """

    def __init__(self, embedding_model: str = "BAAI/bge-large-en-v1.5"):
        self.graph = nx.DiGraph()
        self.embedder = SentenceTransformer(embedding_model)
        self.entity_embeddings = {}

    def add_document(self, doc_id: str, text: str, metadata: Dict[str, Any]):
        """
        Extract entities and relationships, add to knowledge graph
        """
        # 1. Entity extraction (using NER or LLM)
        entities = self._extract_entities(text)

        # 2. Relationship extraction
        relationships = self._extract_relationships(text, entities)

        # 3. Add to graph
        for entity in entities:
            self.graph.add_node(
                entity['id'],
                type=entity['type'],
                name=entity['name'],
                text=text,
                doc_id=doc_id
            )

            # Embed entity
            self.entity_embeddings[entity['id']] = self.embedder.encode(
                f"{entity['name']}: {entity.get('description', '')}"
            )

        for rel in relationships:
            self.graph.add_edge(
                rel['source'],
                rel['target'],
                relation=rel['type'],
                confidence=rel.get('confidence', 1.0)
            )

    def query(
        self,
        question: str,
        max_hops: int = 2,
        top_k_entities: int = 5
    ) -> Dict[str, Any]:
        """
        Query the knowledge graph with multi-hop reasoning
        """
        # 1. Find relevant entities
        query_embedding = self.embedder.encode(question)
        relevant_entities = self._find_relevant_entities(
            query_embedding,
            top_k=top_k_entities
        )

        # 2. Expand via graph traversal
        subgraph_nodes = set()
        for entity_id in relevant_entities:
            subgraph_nodes.update(
                self._expand_entity(entity_id, max_hops=max_hops)
            )

        # 3. Extract subgraph
        subgraph = self.graph.subgraph(subgraph_nodes)

        # 4. Generate answer using subgraph context
        context = self._subgraph_to_context(subgraph)

        return {
            'entities': list(subgraph_nodes),
            'relationships': list(subgraph.edges(data=True)),
            'context': context,
            'graph': subgraph
        }

    def _extract_entities(self, text: str) -> List[Dict[str, Any]]:
        """
        Extract entities using NER or LLM

        In production, use:
        - spaCy NER
        - Hugging Face NER models
        - LLM-based extraction (GPT-4, Claude)
        """
        # Placeholder implementation
        # TODO: Integrate actual NER
        return [
            {'id': 'e1', 'name': 'Entity1', 'type': 'Person'},
            {'id': 'e2', 'name': 'Entity2', 'type': 'Organization'}
        ]

    def _extract_relationships(
        self,
        text: str,
        entities: List[Dict[str, Any]]
    ) -> List[Dict[str, Any]]:
        """
        Extract relationships between entities

        Methods:
        - Dependency parsing (spaCy)
        - Relation extraction models
        - LLM-based extraction
        """
        # Placeholder
        return [
            {
                'source': 'e1',
                'target': 'e2',
                'type': 'works_at',
                'confidence': 0.95
            }
        ]

    def _find_relevant_entities(
        self,
        query_embedding: np.ndarray,
        top_k: int
    ) -> List[str]:
        """
        Find entities most similar to query
        """
        similarities = {}
        for entity_id, embedding in self.entity_embeddings.items():
            similarity = np.dot(query_embedding, embedding) / (
                np.linalg.norm(query_embedding) * np.linalg.norm(embedding)
            )
            similarities[entity_id] = similarity

        # Top K
        sorted_entities = sorted(
            similarities.items(),
            key=lambda x: x[1],
            reverse=True
        )
        return [entity_id for entity_id, _ in sorted_entities[:top_k]]

    def _expand_entity(self, entity_id: str, max_hops: int) -> set:
        """
        Expand entity via graph traversal (BFS)
        """
        visited = set()
        queue = [(entity_id, 0)]

        while queue:
            current, depth = queue.pop(0)
            if depth > max_hops:
                continue

            visited.add(current)

            # Neighbors
            for neighbor in self.graph.neighbors(current):
                if neighbor not in visited:
                    queue.append((neighbor, depth + 1))

        return visited

    def _subgraph_to_context(self, subgraph: nx.DiGraph) -> str:
        """
        Convert subgraph to text context for LLM
        """
        context_parts = []

        # Entities
        for node in subgraph.nodes(data=True):
            node_id, data = node
            context_parts.append(
                f"Entity: {data.get('name', node_id)} ({data.get('type', 'Unknown')})"
            )

        # Relationships
        for edge in subgraph.edges(data=True):
            source, target, data = edge
            relation = data.get('relation', 'related_to')
            source_name = subgraph.nodes[source].get('name', source)
            target_name = subgraph.nodes[target].get('name', target)

            context_parts.append(
                f"Relationship: {source_name} --{relation}--> {target_name}"
            )

        return "\n".join(context_parts)

    def community_detection(self) -> Dict[int, List[str]]:
        """
        Detect communities in the graph for better retrieval

        Use cases:
        - Topic clustering
        - Document grouping
        - Hierarchical retrieval
        """
        from networkx.algorithms import community

        # Louvain community detection
        communities = community.louvain_communities(
            self.graph.to_undirected()
        )

        return {
            i: list(comm)
            for i, comm in enumerate(communities)
        }


# Example Usage
if __name__ == "__main__":
    # Initialize
    graph_rag = GraphRAG()

    # Add documents
    docs = [
        {
            'id': 'doc1',
            'text': 'John works at Google as a software engineer. Google is located in Mountain View.',
            'metadata': {'source': 'company_db'}
        },
        {
            'id': 'doc2',
            'text': 'Mary is the CEO of Anthropic. Anthropic develops Claude AI.',
            'metadata': {'source': 'company_db'}
        }
    ]

    for doc in docs:
        graph_rag.add_document(doc['id'], doc['text'], doc['metadata'])

    # Query (multi-hop)
    result = graph_rag.query(
        "Where does the CEO of the company that develops Claude AI work?",
        max_hops=2
    )

    print("Relevant entities:", result['entities'])
    print("Relationships:", result['relationships'])
    print("\nContext for LLM:")
    print(result['context'])

    # Community detection
    communities = graph_rag.community_detection()
    print("\nCommunities detected:", len(communities))
