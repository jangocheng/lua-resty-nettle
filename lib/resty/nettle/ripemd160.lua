local ffi        = require "ffi"
local ffi_new    = ffi.new
local ffi_typeof = ffi.typeof
local ffi_cdef   = ffi.cdef
local ffi_load   = ffi.load
local ffi_str    = ffi.string

ffi_cdef[[
typedef struct ripemd160_ctx {
  uint32_t state[5];
  uint64_t count;
  uint8_t block[64];
  unsigned int index;
} RIPEMD160_CTX;
void nettle_ripemd160_init(struct ripemd160_ctx *ctx);
void nettle_ripemd160_update(struct ripemd160_ctx *ctx, size_t length, const uint8_t *data);
void nettle_ripemd160_digest(struct ripemd160_ctx *ctx, size_t length, uint8_t *digest);
]]

local nettle = ffi_load("libnettle")

local ctx = ffi_typeof("RIPEMD160_CTX[1]")
local buf = ffi_new("uint8_t[?]", 20)
local ripemd160 = {}
ripemd160.__index = ripemd160

function ripemd160.new()
    local self = setmetatable({ context = ffi_new(ctx) }, ripemd160)
    nettle.nettle_ripemd160_init(self.context)
    return self
end

function ripemd160:update(data)
    return nettle.nettle_ripemd160_update(self.context, #data, data)
end

function ripemd160:digest()
    nettle.nettle_ripemd160_digest(self.context, 20, buf)
    return ffi_str(buf, 20)
end

return ripemd160