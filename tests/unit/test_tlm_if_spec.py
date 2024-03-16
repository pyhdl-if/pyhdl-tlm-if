

def test_param_if():
    import os
    import sys
    unit_tests_dir = os.path.dirname(os.path.abspath(__file__))
    proj_dir = os.path.abspath(os.path.join(unit_tests_dir, "../.."))
    sys.path.append(os.path.join(proj_dir, "src"))

    import vsc_dataclasses as vdc
    import hdl_tlm_if as hti

    @hti.tlm_if
    class BfmIF(object):
        P1 : int = 2
        P2 : int = 3
        P3 : int = P2
        ADDR_WIDTH : vdc.param[int] = 20

        data : vdc.bit_t[P3]

        class AddrWriteReq(object):
            data : vdc.bit_t[lambda : AddrWriteReq.ADDR_WIDTH]
            def __init__(self):
                pass

        class WriteRsp(object):
            pass

        @hti.req_fifo
        async def write_addr_req(self, req : AddrWriteReq):
            pass

        @hti.rsp_fifo
        async def write_rsp(self, rsp : WriteRsp):
            pass




