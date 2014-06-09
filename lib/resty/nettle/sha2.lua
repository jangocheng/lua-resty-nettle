local ffi        = require "ffi"
local ffi_new    = ffi.new
local ffi_typeof = ffi.typeof
local ffi_cdef   = ffi.cdef
local ffi_load   = ffi.load
local ffi_str    = ffi.string

ffi_cdef[[
typedef struct sha256_ctx {
  uint32_t state[8];
  uint64_t count;
  uint8_t block[64];
  unsigned int index;
} SHA256_CTX;
void nettle_sha224_init(struct sha256_ctx *ctx);
void nettle_sha224_digest(struct sha256_ctx *ctx, size_t length, uint8_t *digest);
void nettle_sha256_init(struct sha256_ctx *ctx);
void nettle_sha256_update(struct sha256_ctx *ctx, size_t length, const uint8_t *data);
void nettle_sha256_digest(struct sha256_ctx *ctx, size_t length, uint8_t *digest);
typedef struct sha512_ctx {
  uint64_t state[8];
  uint64_t count_low, count_high;
  uint8_t block[128];
  unsigned int index;
} SHA512_CTX;
void nettle_sha384_init(struct sha512_ctx *ctx);
void nettle_sha384_digest(struct sha512_ctx *ctx, size_t length, uint8_t *digest);
void nettle_sha512_init(struct sha512_ctx *ctx);
void nettle_sha512_update(struct sha512_ctx *ctx, size_t length, const uint8_t *data);
void nettle_sha512_digest(struct sha512_ctx *ctx, size_t length, uint8_t *digest);
void nettle_sha512_224_init(struct sha512_ctx *ctx);
void nettle_sha512_224_digest(struct sha512_ctx *ctx, size_t length, uint8_t *digest);
void nettle_sha512_256_init(struct sha512_ctx *ctx);
void nettle_sha512_256_digest(struct sha512_ctx *ctx, size_t length, uint8_t *digest);
]]

local nettle = ffi_load("libnettle")

local ctx256 = ffi_typeof("SHA256_CTX[1]")
local ctx512 = ffi_typeof("SHA512_CTX[1]")
local buf224 = ffi_new("uint8_t[?]", 28)
local buf256 = ffi_new("uint8_t[?]", 32)
local buf384 = ffi_new("uint8_t[?]", 48)
local buf512 = ffi_new("uint8_t[?]", 64)

local function sha256_update(self, data)
    return nettle.nettle_sha256_update(self.context, #data, data)
end

local function sha512_update(self, data)
    return nettle.nettle_sha512_update(self.context, #data, data)
end

local sha224 = { update = sha256_update }
sha224.__index = sha224

function sha224.new()
    local self = setmetatable({ context = ffi_new(ctx256) }, sha224)
    nettle.nettle_sha224_init(self.context)
    return self
end

function sha224:digest()
    nettle.nettle_sha224_digest(self.context, 28, buf224)
    return ffi_str(buf224, 28)
end

local sha256 = { update = sha256_update }
sha256.__index = sha256

function sha256.new()
    local self = setmetatable({ context = ffi_new(ctx256) }, sha256)
    nettle.nettle_sha256_init(self.context)
    return self
end

function sha256:digest()
    nettle.nettle_sha256_digest(self.context, 32, buf256)
    return ffi_str(buf256, 32)
end

local sha384 = { update = sha512_update }
sha384.__index = sha384

function sha384.new()
    local self = setmetatable({ context = ffi_new(ctx512) }, sha384)
    nettle.nettle_sha384_init(self.context)
    return self
end

function sha384:digest()
    nettle.nettle_sha384_digest(self.context, 48, buf384)
    return ffi_str(buf384, 48)
end

local sha512 = { update = sha512_update }
sha512.__index = sha512

function sha512.new()
    local self = setmetatable({ context = ffi_new(ctx512) }, sha512)
    nettle.nettle_sha512_init(self.context)
    return self
end

function sha512:digest()
    nettle.nettle_sha512_digest(self.context, 64, buf512)
    return ffi_str(buf512, 64)
end

local sha512_224 = { update = sha512_update }
sha512_224.__index = sha512_224

function sha512_224.new()
    local self = setmetatable({ context = ffi_new(ctx512) }, sha512_224)
    nettle.nettle_sha512_224_init(self.context)
    return self
end

function sha512_224:digest()
    nettle.nettle_sha512_224_digest(self.context, 28, buf224)
    return ffi_str(buf224, 28)
end

local sha512_256 = { update = sha512_update }
sha512_256.__index = sha512_256

function sha512_256.new()
    local self = setmetatable({ context = ffi_new(ctx512) }, sha512_256)
    nettle.nettle_sha512_256_init(self.context)
    return self
end

function sha512_256:digest()
    nettle.nettle_sha512_256_digest(self.context, 32, buf256)
    return ffi_str(buf256, 32)
end

return {
    sha224     = sha224,
    sha256     = sha256,
    sha384     = sha384,
    sha512     = sha512,
    sha512_224 = sha512_224,
    sha512_256 = sha512_256
}

