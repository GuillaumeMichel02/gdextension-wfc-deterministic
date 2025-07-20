#include "WFCChunk.hpp"

// Required Godot bindings
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

#include <random> // For std::mt19937 RNG

using namespace godot;

// This function registers the methods that GDScript can call
void WFCChunk::_bind_methods() {
    // Try the standard approach but ensure proper includes
    ClassDB::bind_method(D_METHOD("generate", "seed"), &WFCChunk::generate);
    ClassDB::bind_method(D_METHOD("get_flat_grid"), &WFCChunk::get_flat_grid);
}

// Constructor
WFCChunk::WFCChunk() {
    // Preallocate a 36x36 grid filled with -1 (uninitialized state)
    grid.resize(size, std::vector<int>(size, -1));
}

// Destructor (nothing special here)
WFCChunk::~WFCChunk() {}

// The generation function simulates WFC by randomly assigning tile types
void WFCChunk::generate(int seed) {
    // Create a deterministic RNG using the seed
    std::mt19937 rng(seed);

    // Define tile types between 0 and 4 (you can increase this for more variety)
    std::uniform_int_distribution<int> tile_dist(0, 4);

    // Fill the grid with random tiles using the seeded RNG
    for (int y = 0; y < size; ++y) {
        for (int x = 0; x < size; ++x) {
            grid[y][x] = tile_dist(rng);
        }
    }

    // Print a message to the Godot console
    UtilityFunctions::print("WFCChunk generated with seed: ", seed);
}

// Return a flat 1D array representing the grid to GDScript
TypedArray<int32_t> WFCChunk::get_flat_grid() const {
    TypedArray<int32_t> result;
    result.resize(size * size);

    // Flatten 2D grid into 1D array (row-major order)
    for (int y = 0; y < size; ++y) {
        for (int x = 0; x < size; ++x) {
            result[y * size + x] = grid[y][x];
        }
    }

    return result;
}