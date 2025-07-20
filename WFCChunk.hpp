#ifndef WFC_CHUNK_H
#define WFC_CHUNK_H

// Base Godot class for memory-managed reference counting
#include <godot_cpp/classes/ref_counted.hpp>

// Used to return data to GDScript
#include <godot_cpp/variant/typed_array.hpp>

// Standard library includes
#include <vector>

namespace godot {

// Declare our WFCChunk class, extending RefCounted so it can be used from GDScript
class WFCChunk : public RefCounted {
    GDCLASS(WFCChunk, RefCounted); // Macro to register this class with Godot

private:
    int size = 36; // Full chunk size including margin (e.g., 32 + 2 + 2)
    std::vector<std::vector<int>> grid; // 2D grid storing tile types (or collapsed results)

protected:
    // Bind methods and properties so they're visible to GDScript
    static void _bind_methods();

public:
    WFCChunk();
    ~WFCChunk();

    // Main method to generate WFC chunk given a seed
    void generate(int seed);

    // Return the flattened grid to GDScript as a 1D array
    TypedArray<int32_t> get_flat_grid() const;
};

} // namespace godot

#endif // WFC_CHUNK_H