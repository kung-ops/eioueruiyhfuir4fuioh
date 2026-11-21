#include <stdint.h>
#include <stddef.h>
#include <orbis/libkernel.h>
#include <orbis/VideoOut.h>
#define W 1920
#define H 1080
#define FB_SIZE (W*H*4)
static int video=-1;
static void *memory=NULL;
static off_t mem_offset=0;
static size_t mem_size=0;
static int memory_allocated=0;
static uint32_t *frame[2]={0,0};
static OrbisKernelEqueue queue=0;
static void cleanup(void) {
    if(video>=0){sceVideoOutClose(video);video=-1;}
    if(queue){sceKernelDeleteEqueue(queue);queue=0;}
    if(memory){sceKernelMunmap(memory,mem_size);memory=NULL;}
    if(memory_allocated){sceKernelReleaseDirectMemory(mem_offset,mem_size);memory_allocated=0;}
}
int main(void) {
    video=sceVideoOutOpen(ORBIS_VIDEO_USER_MAIN,ORBIS_VIDEO_OUT_BUS_MAIN,0,0);
    if(video<0)return 1;
    mem_size=(2ULL*FB_SIZE+0x1fffffULL)&~0x1fffffULL;
    if(sceKernelAllocateDirectMemory(0,sceKernelGetDirectMemorySize(),mem_size,0x200000,3,&mem_offset)<0){cleanup();return 2;}
    memory_allocated=1;
    if(sceKernelMapDirectMemory(&memory,mem_size,0x33,0,mem_offset,0x200000)<0){cleanup();return 3;}
    frame[0]=(uint32_t*)memory;
    frame[1]=(uint32_t*)((uint8_t*)memory+FB_SIZE);
    OrbisVideoOutBufferAttribute attr;
    sceVideoOutSetBufferAttribute(&attr,0x80000000,1,0,W,H,W);
    if(sceVideoOutRegisterBuffers(video,0,(void**)frame,2,&attr)!=0){cleanup();return 4;}
    if(sceKernelCreateEqueue(&queue,"homebrew_flip")<0){cleanup();return 5;}
    if(sceVideoOutAddFlipEvent(queue,video,NULL)<0){cleanup();return 6;}
    if(sceVideoOutSetFlipRate(video,0)<0){cleanup();return 7;}
    for(int64_t tick=1;;tick++){
        int active=(int)(tick&1);
        uint32_t *pixels=frame[active];
        int cx=(int)((tick*4)%1400)+250;
        for(int y=0;y<H;y++){
            for(int x=0;x<W;x++){
                uint32_t color=0xff101b31u;
                if(y>=190&&y<885&&x>=190&&x<1730)color=0xff203452u;
                if(y>=210&&y<225&&x>=205&&x<1715)color=0xff42ddc5u;
                if(y>=450&&y<620&&x>=cx-90&&x<cx+90)color=0xff50b8ffu;
                if(y>=740&&y<752&&x>=260&&x<1660)color=0xff3d7ca0u;
                pixels[y*W+x]=color;
            }
        }
        if(sceVideoOutSubmitFlip(video,active,1,tick)<0)break;
        for(;;){
            OrbisVideoOutFlipStatus status={0};
            if(sceVideoOutGetFlipStatus(video,&status)<0)goto done;
            if(status.flipArg==tick)break;
            OrbisKernelEvent event;
            int count=0;
            OrbisKernelUseconds timeout=1000000;
            if(sceKernelWaitEqueue(queue,&event,1,&count,&timeout)!=0)goto done;
        }
    }
done:
    cleanup();
    return 0;
}
