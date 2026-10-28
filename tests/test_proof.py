"""验证 ECS EIP Web 服务完成证明。"""
import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class ProofTest(unittest.TestCase):
    """检查资源状态和计算资源证明。"""

    def test_web_resources_exist(self):
        """功能：验证 Web 资源证明；输入：无；输出：无。"""
        state = json.loads((ROOT / "proof/terraform.tfstate").read_text(encoding="utf-8"))
        types = {item["type"] for item in state["resources"]}
        self.assertTrue(
            {
                "huaweicloud_vpc",
                "huaweicloud_vpc_eip",
                "huaweicloud_compute_instance",
                "huaweicloud_compute_eip_associate",
            }.issubset(types)
        )
        text = json.dumps(state)
        self.assertNotIn('"admin_pass":', text)


if __name__ == "__main__":
    unittest.main()
